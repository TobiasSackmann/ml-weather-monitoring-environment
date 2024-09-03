# Use the official TensorFlow Serving image as the base image
FROM tensorflow/serving:latest

# Set a working directory
WORKDIR /models

# Copy your TensorFlow model (saved_model format) to the container
# Replace 'my_model' with your actual model directory
COPY waether-timeseries-forecast.keras /models/waether-timeseries-forecast.keras

# Set the environment variable for TensorFlow Serving to load the model
ENV MODEL_NAME=waether-timeseries-forecast

# Expose the default TensorFlow Serving port
EXPOSE 8501

# Start TensorFlow Serving and serve the model
ENTRYPOINT ["/usr/bin/tensorflow_model_server", "--model_base_path=/models/my_model", "--rest_api_port=8501", "--model_name=my_model"]
