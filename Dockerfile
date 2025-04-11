# Stage 1: Build with Gradle
FROM gradle:7.6.3-jdk11 AS builder

WORKDIR /app

# Create minimal settings.gradle
RUN echo "rootProject.name = 'autoinsurance'" > settings.gradle

# Copy build files
COPY build.gradle gradle.properties /app/
COPY gradle /app/gradle

# Create required directories
RUN mkdir -p src/main/webapp

# Copy source files
COPY src /app/src
COPY desktop_app /app/desktop_app

# Build the application
RUN gradle clean build writeGitCommitToFile --no-daemon -x test

# Stage 2: Runtime with Tomcat
FROM tomcat:9.0-jdk11-openjdk-slim

# Configure Tomcat
RUN rm -rf /usr/local/tomcat/webapps/ROOT && \
    mkdir -p /usr/local/tomcat/conf/Catalina/localhost

# Copy the built WAR file
COPY --from=builder /app/build/libs/*.war /usr/local/tomcat/webapps/ROOT.war

# Copy database files
COPY --from=builder /app/build/db /usr/local/tomcat/db

# Environment variables
ENV DB_URL=jdbc:h2:file:/usr/local/tomcat/db/training
ENV DB_DRIVER=org.h2.Driver

EXPOSE 8080 8000
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/demo/ || exit 1

CMD ["catalina.sh", "jpda", "run"]