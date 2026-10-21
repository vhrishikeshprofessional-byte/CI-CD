# Build & test stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project definitions for layer caching
COPY DotnetHello.sln .
COPY src/DotnetHello/DotnetHello.csproj src/DotnetHello/
COPY tests/DotnetHello.Tests/DotnetHello.Tests.csproj tests/DotnetHello.Tests/
RUN dotnet restore

# Copy all sources and build
COPY . .
RUN dotnet build -c Release --no-restore
RUN dotnet test -c Release --no-build --verbosity normal
RUN dotnet publish src/DotnetHello/DotnetHello.csproj -c Release -o /app/publish --no-build

# Production runtime stage (Alpine hardened non-root container)
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

COPY --from=build /app/publish .

# Run as built-in non-root app user (UID 1654)
USER $APP_UID
ENTRYPOINT ["dotnet", "DotnetHello.dll"]
