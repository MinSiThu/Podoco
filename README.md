# Podoco - Plant Disease Classifier App

Flutter App that can classify cassava plant diseases offline, using tflite.

<img src="/screenshots/main2.jpg" width='100' height="350">
<img src="/screenshots/main.jpg" width='100' height="350">
<img src="/screenshots/about.jpg" width='100' height="350">

## About Model

This model is trained to classify an input image into one of 6 cassava disease classes: Bacterial Blight, Brown Streak Disease, Green Mite, Mosaic Disease, Healthy, and Unknown.

The training dataset is curated by the Mak-AI team at the Makerere University.

## Suitable usecases
This model is trained to recognize four Cassava diseases.

## Unsuitable usecases
This model does not detect diseases in other plants.

## Known limitations
- This model assumes that the input contains a well-cropped image of a Cassava plant. If the image contains some other plant, the output results may be meaningless.
- In some cases, the model may misdiagnose or falsely diagnose a cassava disease. A misdiagnosed result might lead to the wrong treatment course being applied to cassava plants in the field.
- This model should generally work on cassava plants from around the world, but was trained only on photos of diseased cassava plants taken in Uganda


