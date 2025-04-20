ASL CNN Training & Quantization Details

---------------------------------------------

1. Dataset Information
- Dataset: American Sign Language (ASL) Alphabet
- Excluded Classes: Dynamic gestures (J, Z)
- Total Classes Used: 24 (A-Z excluding J, Z)

- Data Augmentation:
  * Each original image augmented into 20 variations
  * Augmentation methods:
    - Rotation: ±10°
    - Translation: ±10 pixels (horizontal & vertical)
    - Scaling: 80% ~ 120% of original size
    - Brightness & Saturation Adjustment: 60% ~ 140%
    - Hue Shift: ±0.2 range
    - Gaussian Blur: 50% probability (sigma: 0 ~ 1.0)
    - Random Grayscale Inversion: 15% probability

---------------------------------------------

2. CNN Architecture
- Input: 32×32×3 (RGB images)

- Convolutional Layers:
  1) Conv1: 8 filters (3×3), Padding='same', Activation=ReLU
     Max Pooling (2×2, stride=2)
  2) Conv2: 16 filters (3×3), Padding='same', Activation=ReLU
     Max Pooling (2×2, stride=2)
  3) Conv3: 24 filters (3×3), Padding='same', Activation=ReLU
     Max Pooling (2×2, stride=2)

- Fully Connected Layers:
  - FC1: 64 nodes
  - Dropout Layer: 0.5 ratio
  - FC2: 24 nodes (number of classes)

- Output: Softmax activation

---------------------------------------------

3. Training Information
- Framework: MATLAB
- Optimizer: Adam
- Initial Learning Rate: 0.001
- Epochs: 8
- Batch Size: 32
- L2 Regularization: 0.01

- Performance:
  * Validation Accuracy: 96.74%
  * Test Accuracy: 97.09%

---------------------------------------------

4. Fixed-Point Quantization
- Method: Fixed-point (8-bit total)
- Format: Signed, 1 Sign bit, 2 Integer bits, 5 Fractional bits (1.2.5 format)
- Tool: MATLAB Fixed-Point Designer (fi function)

- Post-Quantization Performance:
  * Test Accuracy: 97.46%

---------------------------------------------

5. Inference on External Test Set (./2.Dataset/test_img)
- Results (Correct: O, Incorrect: X):

  a.jpeg → Predicted: A (O)  
  b.jpeg → Predicted: B (O)  
  c.jpeg → Predicted: G (X)  
  d.jpeg → Predicted: R (X)  
  e.jpeg → Predicted: A (X)  
  f.jpeg → Predicted: F (O)  
  g.jpeg → Predicted: H (X)  
  h.jpeg → Predicted: H (O)  
  i.jpeg → Predicted: I (O)  
  k.jpeg → Predicted: V (X)  
  l.jpeg → Predicted: L (O)  
  m.jpeg → Predicted: I (X)  
  n.jpeg → Predicted: X (X)  
  o.jpeg → Predicted: R (X)  
  p.jpeg → Predicted: P (O)  
  q.jpeg → Predicted: Q (O)  
  r.jpeg → Predicted: R (O)  
  s.jpeg → Predicted: D (X)  
  t.jpeg → Predicted: T (O)  
  u.jpeg → Predicted: U (O)  
  v.jpeg → Predicted: V (O)  
  w.jpeg → Predicted: W (O)  
  x.jpeg → Predicted: D (X)  
  y.jpeg → Predicted: Y (O)  

- Accuracy on External Data: 14 out of 24 correct (58.33%)

- Observations:
  * Misclassifications primarily occur among visually similar signs (e.g., M, N, S, T).
  * Indicates potential confusion due to similarities or background variations.

---------------------------------------------

6. Output Files
- Original Model: "trained_net.”mat
- Quantized Model: "manually_quant_net.mat"
- Parameters Exported: Binary files (.bin) for weights and biases stored in the "quantized_binary_params" folder.