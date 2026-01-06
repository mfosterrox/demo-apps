package com.example;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.webapp.WebAppContext;
import java.net.URL;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.jar.JarFile;
import java.util.jar.JarEntry;

public class StrutsServer {
    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(System.getProperty("port", "8080"));
        Server server = new Server(port);
        
        WebAppContext context = new WebAppContext();
        context.setContextPath("/");
        
        // Get the JAR location
        URL location = StrutsServer.class.getProtectionDomain().getCodeSource().getLocation();
        String jarPath = location.toExternalForm();
        
        // Extract webapp resources from JAR to temp directory
        File tempWebappDir = new File(System.getProperty("java.io.tmpdir"), "struts-webapp-" + System.currentTimeMillis());
        tempWebappDir.mkdirs();
        
        if (jarPath.startsWith("jar:")) {
            // Extract webapp directory from JAR
            String jarFile = jarPath.substring(9, jarPath.indexOf("!"));
            try (JarFile jar = new JarFile(new File(java.net.URI.create(jarFile)))) {
                jar.stream().filter(entry -> entry.getName().startsWith("webapp/"))
                    .forEach(entry -> {
                        try {
                            Path targetPath = tempWebappDir.toPath().resolve(entry.getName().substring(7)); // Remove "webapp/" prefix
                            if (entry.isDirectory()) {
                                Files.createDirectories(targetPath);
                            } else {
                                Files.createDirectories(targetPath.getParent());
                                try (InputStream is = jar.getInputStream(entry)) {
                                    Files.copy(is, targetPath);
                                }
                            }
                        } catch (Exception e) {
                            System.err.println("Error extracting " + entry.getName() + ": " + e.getMessage());
                        }
                    });
            }
            context.setResourceBase(tempWebappDir.getAbsolutePath());
        } else {
            // Running from classes directory (development)
            File classesDir = new File(location.toURI());
            File webappDir = new File(classesDir.getParentFile().getParentFile(), "webapp");
            context.setResourceBase(webappDir.getAbsolutePath());
        }
        
        context.setParentLoaderPriority(true);
        
        server.setHandler(context);
        server.start();
        System.out.println("Apache Struts application started on port " + port);
        System.out.println("Access the application at: http://localhost:" + port);
        server.join();
    }
}

