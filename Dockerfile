## Step 1:
# Install Python base Image
FROM python:3.7.3-stretch

## Step 2:
# Create a working directory
WORKDIR /app

## Step 3:
# Copy source code to working directory
COPY . /app/

## Step 4:
# Install packages from requirements.txt
# hadolint ignore=DL3013
RUN pip3 install --upgrade pip &&\
    pip3 install -r requirements.txt

## Step 5:
# Expose port 5000
EXPOSE 5000

## Step 6:
# Run app.py at container launch
CMD ["python", "app.py"]
