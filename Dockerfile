# Use the official Python image from the Docker Hub
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Copy the pyproject.toml and poetry.lock files into the container
COPY pyproject.toml poetry.lock ./

# Install Poetry
RUN pip install --no-cache-dir poetry

# Update poetry
RUN poetry lock --no-update

# Install the dependencies using Poetry
RUN poetry install --no-root --no-dev

# Copy the rest of the application code into the container
COPY . .

# Expose the port the app runs on
EXPOSE 3000