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

model = YOLO("model.pt", task="pose")

def get_img_from_base64(base64img):
    img_bytes = base64.b64decode(base64img)
    img_buffer = np.frombuffer(img_bytes, dtype=np.uint8)
    img = imdecode(img_buffer, flags=-1)
    return img

@app.route("/image", methods=['GET', 'POST'])
def image(): 
    request_json = request.json

    base64_image_data = request_json["image"][22:]
    img = get_img_from_base64(base64_image_data)[:,:,:3]
    img = (255-img)

    imwrite(f"new_data/{str(uuid.uuid4())[:6]}.png", img=img)

    # Classify!
    results = model(img, verbose=True)
    output = []

    for r in results:
        classes = r.names
        bx = r.boxes
        for i, bx_xywh in enumerate(bx.xywh):
            res = bx.xywh[i].cpu().numpy()
            output.append({
                "type": str(classes[int(bx.cls[i].cpu().numpy().tolist())]),
                "location": [int(res[0]), int(res[1])],
                "size": [int(res[2]), int(res[3])],
                "confidence": float(r.boxes.conf[i].cpu().numpy())
            })

    return output

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=3000, debug=True)