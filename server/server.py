import cv2
from flask import Flask
from flask import request
from flask_cors import CORS
from ultralytics import YOLO
import uuid

import numpy as np
from cv2 import imdecode, imwrite
import base64

app = Flask(__name__, static_url_path='/')
cors = CORS(app)
app.config['SECRET_KEY'] = 'secret!'

model = YOLO("model.pt", task="classify")

def get_img_from_base64(base64img):
    img_bytes = base64.b64decode(base64img)
    img_buffer = np.frombuffer(img_bytes, dtype=np.uint8)
    img = imdecode(img_buffer, flags=-1)
    return img

def crop_img(img):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # Threshold the image so that black text is white
    gray = 255*(gray < 128).astype(np.uint8)
    # Additionally do an opening operation with a 2 x 2 kernel
    O = np.ones(2, dtype=np.uint8)
    gray_morph = cv2.morphologyEx(gray, cv2.MORPH_OPEN, O)
    # Continue where we left off
    coords = cv2.findNonZero(gray_morph) # Find all non-zero points (text)
    xywh = cv2.boundingRect(coords) # Find minimum spanning bounding box
    xyxy = (xywh[0], xywh[1], xywh[0] + xywh[2], xywh[1] + xywh[3])
    return img[xywh[1]:xywh[1] + xywh[3], xywh[0]:xywh[0] + xywh[2]]

@app.route("/image", methods=['GET', 'POST'])
def image(): 
    request_json = request.json
    # print(request_json["image"])

    base64_image_data = request_json["image"][22:]
    img = get_img_from_base64(base64_image_data)[:,:,:3]
    img = (255-img)
    imwrite(f"new_data/{str(uuid.uuid4())[:6]}.png", img=img)

    img = crop_img(img)
    imwrite(f"new_data/copped_{str(uuid.uuid4())[:6]}.png", img=img)
    # Classify!
    results = model(img, verbose=True)
    
    output = []

    for r in results:
        classes = r.names
        class_idx = r.probs.top1
        confidence = r.probs.top1conf.cpu().numpy()
        output.append({
            "type": str(classes[class_idx]),
            "confidence": float(confidence)
        })

    return output

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000, debug=True)