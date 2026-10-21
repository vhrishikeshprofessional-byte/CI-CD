# Build stage
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline || true
COPY src ./src
RUN mvn -B clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN apk update && apk upgrade --no-cache && \
    adduser -D -u 10001 appuser
COPY --from=build /app/target/java-hello-1.0.0.jar app.jar
USER 10001
ENTRYPOINT ["java", "-jar", "app.jar"]
