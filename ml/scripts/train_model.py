import os

import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, Dropout, GlobalAveragePooling2D
from tensorflow.keras.models import Model


IMAGE_SIZE = 224
BATCH_SIZE = 32
EPOCHS = 10


BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

TRAIN_DIR = os.path.join(BASE_DIR, "dataset_raw", "indoor", "train")
VALIDATION_DIR = os.path.join(BASE_DIR, "dataset_raw", "indoor", "valid")
TEST_DIR = os.path.join(BASE_DIR, "dataset_raw", "indoor", "test")

MODELS_DIR = os.path.join(BASE_DIR, "models")


def main():
    print("Проверка структуры датасета...")

    print(f"Train: {TRAIN_DIR}")
    print(f"Validation: {VALIDATION_DIR}")
    print(f"Test: {TEST_DIR}")

    os.makedirs(MODELS_DIR, exist_ok=True)

    train_datagen = ImageDataGenerator(
        rescale=1.0 / 255,
        rotation_range=20,
        zoom_range=0.2,
        horizontal_flip=True,
    )

    validation_datagen = ImageDataGenerator(
        rescale=1.0 / 255,
    )

    train_generator = train_datagen.flow_from_directory(
        TRAIN_DIR,
        target_size=(IMAGE_SIZE, IMAGE_SIZE),
        batch_size=BATCH_SIZE,
        class_mode="categorical",
    )

    validation_generator = validation_datagen.flow_from_directory(
        VALIDATION_DIR,
        target_size=(IMAGE_SIZE, IMAGE_SIZE),
        batch_size=BATCH_SIZE,
        class_mode="categorical",
    )

    print("Классы датасета:")
    print(train_generator.class_indices)

    num_classes = len(train_generator.class_indices)

    print(f"Количество классов: {num_classes}")

    base_model = MobileNetV2(
        weights="imagenet",
        include_top=False,
        input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3),
    )

    base_model.trainable = False

    x = base_model.output
    x = GlobalAveragePooling2D()(x)
    x = Dropout(0.3)(x)

    predictions = Dense(
        num_classes,
        activation="softmax",
    )(x)

    model = Model(
        inputs=base_model.input,
        outputs=predictions,
    )

    model.compile(
        optimizer="adam",
        loss="categorical_crossentropy",
        metrics=["accuracy"],
    )

    print("Начало обучения модели...")

    history = model.fit(
        train_generator,
        validation_data=validation_generator,
        epochs=EPOCHS,
    )

    model_path = os.path.join(
        MODELS_DIR,
        "plant_disease_model.h5",
    )

    model.save(model_path)

    print(f"Модель сохранена: {model_path}")


if __name__ == "__main__":
    main()