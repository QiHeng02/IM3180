from firebase_functions import firestore_fn, https_fn, options
from firebase_admin import initialize_app, storage as admin_storage, firestore as admin_fs
from PIL import Image
import io, os, joblib, numpy as np
import cv2
import tempfile

# ----------------------------
# Firebase setup
# ----------------------------
options.set_global_options(region="us-central1")
initialize_app()

_MODEL = None
_SCALER = None

def _load_model():
    global _MODEL, _SCALER
    base = os.path.dirname(__file__)
    if _MODEL is None:
        _MODEL = joblib.load(os.path.join(base, "svr_model.pkl"))
    if _SCALER is None:
        _SCALER = joblib.load(os.path.join(base, "scaler.pkl"))

# ----------------------------
# Feature extraction (from your 2nd program)
# ----------------------------
def extract_features_from_image_cv(img_cv):
    lab = cv2.cvtColor(img_cv, cv2.COLOR_BGR2LAB)
    l_mean, a_mean, b_mean = np.mean(lab[:, :, 0]), np.mean(lab[:, :, 1]), np.mean(lab[:, :, 2])
    l_std, a_std, b_std = np.std(lab[:, :, 0]), np.std(lab[:, :, 1]), np.std(lab[:, :, 2])

    b_mean_rgb, g_mean_rgb, r_mean_rgb = np.mean(img_cv[:, :, 0]), np.mean(img_cv[:, :, 1]), np.mean(img_cv[:, :, 2])
    b_std_rgb, g_std_rgb, r_std_rgb = np.std(img_cv[:, :, 0]), np.std(img_cv[:, :, 1]), np.std(img_cv[:, :, 2])

    lab_feats = [l_mean, l_std, a_mean, a_std, b_mean, b_std]
    rgb_feats = [r_mean_rgb, g_mean_rgb, b_mean_rgb]
    return lab_feats, rgb_feats


def predict_ph_from_cv(img_cv):
    _load_model()

    lab_feats, rgb_feats = extract_features_from_image_cv(img_cv)

    try:
        expected_n_features = _SCALER.n_features_in_
    except Exception:
        expected_n_features = None

    # Determine feature combinations
    if expected_n_features is None:
        feature_candidates = [lab_feats + rgb_feats, lab_feats]
    elif expected_n_features == 9:
        feature_candidates = [lab_feats + rgb_feats]
    elif expected_n_features == 6:
        feature_candidates = [lab_feats]
    else:
        raise ValueError(f"Scaler expects {expected_n_features} features which is unsupported")

    last_err = None
    for feats in feature_candidates:
        try:
            feats_scaled = _SCALER.transform([feats])
            ph_pred = _MODEL.predict(feats_scaled)[0]
            return float(ph_pred)
        except Exception as e:
            last_err = e
    raise RuntimeError(f"Failed to transform features: {last_err}")

# ----------------------------
# Safe pH reference
# ----------------------------
SAFE_PH = {
    "chicken":  (5.8, 6.4),
    "tofu":     (6.8, 7.4),
    "blueberry":(2.8, 3.6),
    "apple":    (3.0, 4.0),
}

def _classify(ph: float, rmin: float, rmax: float):
    margin = 0.2
    if rmin <= ph <= rmax:
        return "fresh", 48, True
    if (rmin - margin) <= ph <= (rmax + margin):
        return "moderate", 24, False
    return "spoiled", 0, False


# ----------------------------
# Firestore trigger
# ----------------------------
@firestore_fn.on_document_created(document="users/{userId}/scans/{scanId}")
def on_scan_created(event: firestore_fn.Event[firestore_fn.DocumentSnapshot]) -> None:
    snap = event.data
    if snap is None:
        return
    d = snap.to_dict() or {}
    if d.get("status") != "pending" or not d.get("storagePath"):
        return

    storage_path = d["storagePath"]
    food = (d.get("selectedFood") or d.get("food") or "").strip().lower()
    category = (d.get("selectedCategory") or d.get("category") or "").strip()

    try:
        _load_model()

        # Download image from Firebase Storage
        bucket = admin_storage.bucket()
        img_bytes = bucket.blob(storage_path).download_as_bytes()

        # Decode with OpenCV directly (no temp file)
        np_buf = np.frombuffer(img_bytes, np.uint8)
        img_cv = cv2.imdecode(np_buf, cv2.IMREAD_COLOR)
        if img_cv is None:
            raise RuntimeError("cv2.imdecode failed — invalid image bytes")

        # Predict using training-aligned features
        ph = predict_ph_from_cv(img_cv)

        # Classify freshness
        rmin, rmax = SAFE_PH.get(food, (6.0, 7.0))
        freshness, hours, is_safe = _classify(ph, rmin, rmax)

        # Update Firestore doc
        snap.reference.update({
            "status": "complete",
            "phValue": ph,
            "freshness": freshness,
            "hoursToConsume": hours,
            "isInSafeRange": is_safe,
            "safePhMin": rmin,
            "safePhMax": rmax,
            "selectedFood": food,
            "selectedCategory": category,
            "modelVersion": "svr_v2",
            "inferredAt": admin_fs.SERVER_TIMESTAMP,
        })

    except Exception as e:
        snap.reference.update({
            "status": "error",
            "errorMessage": str(e),
        })


# ----------------------------
# Health check endpoint
# ----------------------------
@https_fn.on_request()
def health(req: https_fn.Request):
    return https_fn.Response("OK", status=200)
