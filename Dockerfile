# Use official Python image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy files into container
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Expose port
EXPOSE 5000

# Run application
CMD ["python", "app.py"]
