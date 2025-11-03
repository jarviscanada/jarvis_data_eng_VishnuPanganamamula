package ca.jrvs.apps.grep;

import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

public class JavaGrepClass implements JavaGrep {

    final Logger logger = Logger.getLogger(JavaGrep.class.getName());

    private String regex;
    private String rootPath;
    private String outFile;

    public static void main(String[] args) {
        if (args.length != 3){
            throw new IllegalArgumentException("USAGE: JavaGrep regex rootPath outFile");
        }

        JavaGrepClass javaGrepClass = new JavaGrepClass();
        javaGrepClass.setRegex(args[0]);
        javaGrepClass.setRootPath(args[1]);
        javaGrepClass.setOutFile(args[2]);

        try {
            javaGrepClass.process();
        } catch (IOException ex){
            javaGrepClass.logger.log(Level.SEVERE,"Error: Unable to process", ex);
        }
    }


    @Override
    public void process() throws IOException {
        List<String> matchedLines = new ArrayList<>();

        // Lists the files in a recursive way
        for (File file: listFiles(rootPath)){
            // Reads every line
            for (String line: readLines(file)){
                // Checks for pattern and adds to 'matchedLines' list if there is a match
                if (containsPattern(line)){
                    matchedLines.add(line);
                }
            }
        }
        // Logs matching line to the output file
        writeToFile(matchedLines);
    }

    @Override
    public List<File> listFiles(String rootDir) {
        List<File> result = new ArrayList<>();
        File root = new File(rootPath);

        if(!root.exists()) {
            logger.log(Level.WARNING, "root path does not exist" + rootDir);
            return result;
        }

        File[] files = root.listFiles();
        if(files != null) {
            for(File f: files) {
                if (f.isDirectory()){
                    result.addAll(listFiles(f.getAbsolutePath()));
                } else {
                    result.add(f);
                }
            }
        }

        return result;
    }

    @Override
    public List<String> readLines(File inputFile) {
        List<String> lines = new ArrayList<>();
        try (BufferedReader reader = new BufferedReader(new FileReader(inputFile))) {
            String line;
            while((line = reader.readLine()) != null) {
                lines.add(line);
            }
        } catch (IOException e) {
            logger.log(Level.WARNING, "Error reading file " + inputFile, e);
        }

        return lines;
    }

    @Override
    public Boolean containsPattern(String line) {
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(line);

        return matcher.find();
    }

    @Override
    public void writeToFile(List<String> lines) throws IOException {
        File file = new File(outFile);
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(file))) {
            for (String line: lines) {
                writer.write(line);
                writer.newLine();
            }
        } catch (IOException e) {
            logger.log(Level.SEVERE, "Error writing to file: " + outFile, e);
            throw e;
        }
    }

    @Override
    public String getRootPath() {
        return rootPath;
    }

    @Override
    public void setRootPath(String rootPath) {
        this.rootPath = rootPath;
    }

    @Override
    public String getRegex() {
        return regex;
    }

    @Override
    public void setRegex(String regex) {
        this.regex = regex;
    }

    @Override
    public String getOutFile() {
        return outFile;
    }

    @Override
    public void setOutFile(String outFile) {
        this.outFile = outFile;
    }
}
