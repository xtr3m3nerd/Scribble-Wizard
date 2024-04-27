from ultralytics import YOLO

if __name__ == "__main__":
    model = YOLO('yolov8n-cls.pt')
    results = model.train(
        data=f'training/data', 
        epochs=25,
        imgsz=128
    )
