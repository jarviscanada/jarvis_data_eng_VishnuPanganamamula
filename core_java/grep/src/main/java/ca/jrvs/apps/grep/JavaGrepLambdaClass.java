package ca.jrvs.apps.grep;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class JavaGrepLambdaClass extends JavaGrepClass {

    public static void main(String[] args) {

        if (args.length != 3) {
            throw new IllegalArgumentException("USAGE: JavaGrep regex rootPath outFile");
        }

        JavaGrepLambdaClass javaGrepLambdaClass = new JavaGrepLambdaClass();
        javaGrepLambdaClass.setRegex(args[0]);
        javaGrepLambdaClass.setRootPath(args[1]);
        javaGrepLambdaClass.setOutFile(args[2]);

        try {
            javaGrepLambdaClass.process();
        } catch (Exception ex) {
            javaGrepLambdaClass.logger.log(Level.SEVERE,"Error: Unable to process", ex);
        }
    }

    @Override
    public List<File> listFiles(String rootDir) {

        try{
            return Files.walk(Paths.get(rootDir))
                    .filter(Files::isRegularFile)
                    .map(Path::toFile)
                    .collect(Collectors.toList());

        } catch (IOException e) {
            logger.log(Level.WARNING, "Could not go through directory: " + rootDir, e);
            return Collections.emptyList();
        }
    }

    @Override
    public List<String> readLines(File inputFile) {

        try (Stream<String> lines = Files.lines(inputFile.toPath())) {
            return lines.collect(Collectors.toList());
        } catch (IOException ex) {
            logger.log(Level.WARNING, "Error with reading file: " + inputFile, ex);
            return Collections.emptyList();
        }
    }

}
