#step 1: build
FROM --platform=$BUILDPLATFORM docker.io/gradle:7.3.1-jdk17 AS builder
COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src
ENV GRADLE_OPTS="-Xmx2048m -Dorg.gradle.daemon=false -Dorg.gradle.parallel=false"
RUN chmod +x gradlew && ./gradlew bootJar --no-daemon -x test

#step 2: target
FROM --platform=$TARGETPLATFORM docker.io/eclipse-temurin:8-jre
EXPOSE 8080
RUN mkdir /app
COPY --from=builder /home/gradle/src/build/libs/*.jar /app/spring-boot-application.jar
# Override entrypoint to avoid architecture-specific __cacert_entrypoint.sh issues
ENTRYPOINT []
CMD ["java", "-jar", "/app/spring-boot-application.jar"]
