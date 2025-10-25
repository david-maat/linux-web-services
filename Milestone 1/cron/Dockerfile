FROM docker:cli

# Install cron (dcron) and bash
RUN apk add --no-cache dcron bash

# Copy the crontab file into the container
COPY crontab /etc/crontabs/root

# Optional: verify syntax (good for debugging builds)
RUN crontab -l

# Run cron in the foreground so the container stays alive
CMD ["crond", "-f", "-d", "8"]
