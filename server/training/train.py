from ultralytics import YOLO

if __name__ == "__main__":
    model = YOLO('yolov8n.pt')
    results = model.train(
        data=f'training/data/data.yaml', 
        epochs=25,
        imgsz=128
    )
