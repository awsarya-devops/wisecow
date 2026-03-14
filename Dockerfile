FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    fortune-mod \
    cowsay \
    netcat-openbsd \
    bash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add cowsay to PATH
ENV PATH="/usr/games:${PATH}"

# Set working directory
WORKDIR /app

# Copy the wisecow script
COPY wisecow.sh .

# Make it executable
RUN chmod +x wisecow.sh

# Expose the port wisecow runs on
EXPOSE 4499

# Run the app
CMD ["bash", "wisecow.sh"]
