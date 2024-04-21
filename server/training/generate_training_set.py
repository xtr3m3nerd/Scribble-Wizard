import os
import shutil
import random
import numpy as np
import cv2
from PIL import Image 

classes = ["lightning", "fire", "water"]
categories = ["train", "train", "train", "train", "train", "valid", "test"]

os.makedirs("training/data/test/images", exist_ok=True)
os.makedirs("training/data/test/labels", exist_ok=True)
os.makedirs("training/data/train/images", exist_ok=True)
os.makedirs("training/data/train/labels", exist_ok=True)
os.makedirs("training/data/valid/images", exist_ok=True)
os.makedirs("training/data/valid/labels", exist_ok=True)

def resize_img(filename):
    img = Image.open(filename)
    img = img.resize((640, 640), Image.Resampling.LANCZOS)
    img.save(filename)

def find_content(filename):
    img = cv2.imread(filename) # image file
    height, width, channels = img.shape
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # Threshold the image so that black text is white
    gray = 255*(gray < 128).astype(np.uint8)
    # Additionally do an opening operation with a 2 x 2 kernel
    O = np.ones(2, dtype=np.uint8)
    gray_morph = cv2.morphologyEx(gray, cv2.MORPH_OPEN, O)
    # Continue where we left off
    coords = cv2.findNonZero(gray_morph) # Find all non-zero points (text)
    x, y, w, h = cv2.boundingRect(coords) # Find minimum spanning bounding box
    return f"{(x+(w/2))/width} {(y+(h/2))/height} {w/width} {h/height}"

for (c_idx, c) in enumerate(classes):
    folder = f"images/{c}"
    for filename in os.listdir(folder):
        cat = random.choice(categories)
        shutil.copyfile(f"{folder}/{filename}", f"training/data/{cat}/images/{c_idx}_{filename}")
        resize_img(f"training/data/{cat}/images/{c_idx}_{filename}")

        with open(f"training/data/{cat}/labels/{c_idx}_{filename[:-4]}.txt", "w") as file:
            file.write(f"{c_idx} {find_content(f'{folder}/{filename}')}")
