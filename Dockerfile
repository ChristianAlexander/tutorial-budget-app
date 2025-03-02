# Use the official Elixir image.
FROM elixir:1.18.2

# Install Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set the working directory.
WORKDIR /app

# Copy the mix files.
COPY mix.exs mix.lock ./

# Install dependencies.
RUN mix deps.get

# Copy the rest of the project files.
COPY . .

# Expose port 4000.
EXPOSE 4000

# Start the Phoenix server.
CMD ["mix", "phx.server"]

