import os
import tensorflow as tf


BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

H5_MODEL_PATH = os.path.join(
    BASE_DIR,
    "models",
    "plant_disease_model.h5",
)

TFLITE_MODEL_PATH = os.path.join(
    BASE_DIR,
    "models",
    "plant_disease_model.tflite",
)


def main():
    print("Загрузка модели .h5...")
    model = tf.keras.models.load_model(H5_MODEL_PATH)

    print("Конвертация модели в TensorFlow Lite...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)

    tflite_model = converter.convert()

    with open(TFLITE_MODEL_PATH, "wb") as file:
        file.write(tflite_model)

    print(f"TensorFlow Lite модель сохранена: {TFLITE_MODEL_PATH}")


if __name__ == "__main__":
    main()