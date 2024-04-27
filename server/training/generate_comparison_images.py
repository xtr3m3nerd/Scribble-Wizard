import os
import shutil
import random
import numpy as np
import cv2
from PIL import Image 

classes = ["lightning", "fire", "water"]
categories = ["train", "train", "train", "train", "train", "valid", "test"]

os.makedirs("training/comparison_images", exist_ok=True)

def resize_img(filename, box):
    img = Image.open(filename)
    img = img.crop(box)
    img = img.resize((48, 48), Image.Resampling.LANCZOS)
    img.save(filename)

def find_content(filename):
    img = cv2.imread(filename) # image file
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
    return xyxy

for (c_idx, c) in enumerate(classes):
    folder = f"images/{c}"
    os.makedirs(f"training/comparison_images/{c}", exist_ok=True)
    for filename in os.listdir(folder):
        cat = random.choice(categories)
        shutil.copyfile(f"{folder}/{filename}", f"training/comparison_images/{c}/{c_idx}_{filename}")
        bounding_box = find_content(f'{folder}/{filename}')
        resize_img(f"training/comparison_images/{c}/{c_idx}_{filename}", bounding_box)
