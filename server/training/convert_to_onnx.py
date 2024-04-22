from ultralytics import YOLO

# Load a YOLOv8n PyTorch model
dart_model = YOLO('best.pt')
dart_model.export(format='onnx')

