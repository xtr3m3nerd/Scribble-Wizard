from ultralytics import YOLO

# Load a YOLOv8n PyTorch model
dart_model = YOLO('model.pt')
dart_model.export(format='onnx', opset=12, imgsz=128)
