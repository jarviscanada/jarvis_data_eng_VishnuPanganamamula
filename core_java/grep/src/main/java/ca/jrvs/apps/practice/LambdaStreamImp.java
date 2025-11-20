package ca.jrvs.apps.practice;

import java.util.Collections;
import java.util.List;
import java.util.function.Consumer;
import java.util.stream.Collectors;
import java.util.stream.DoubleStream;
import java.util.stream.IntStream;
import java.util.stream.Stream;

public class LambdaStreamImp implements LambdaStreamExc {

    public static void main(String[] args) {
        LambdaStreamImp ls_imp = new LambdaStreamImp();

        // print odd numbers
        System.out.println("\n--- Odd Numbers ---");
        ls_imp.printOdd(ls_imp.createIntStream(0, 9), ls_imp.getLambdaPrinter("odd number ", "!"));

        // Square root of intStream
        System.out.println("\n--- Square Root ---");
        ls_imp.squareRootIntStream(ls_imp.createIntStream(new int[] {1, 4, 9, 16, 25, 36})).forEach(System.out::println);

        // Filter names that do not have the pattern
        System.out.println("\n--- Filter Pattern ---");
        Stream<String> names = Stream.of("Leon", "Jill", "Claire", "Ashley", "Chris", "Sherry");
        ls_imp.filter(names, "h").forEach(System.out::println);
    }

    @Override
    public Stream<String> createStrStream(String... strings) {
        return Stream.of(strings);
    }

    @Override
    public Stream<String> toUpperCase(String... strings) {
        return createStrStream(strings).map(String::toUpperCase);
    }

    @Override
    public Stream<String> filter(Stream<String> stringStream, String pattern) {
        return stringStream.filter(str -> !str.contains(pattern));
    }

    @Override
    public IntStream createIntStream(int[] arr) {
        return IntStream.of(arr);
    }

    @Override
    public <E> List<E> toList(Stream<E> stream) {
        return stream.collect(Collectors.toList());
    }

    @Override
    public List<Integer> toList(IntStream intStream) {
        return intStream.boxed().collect(Collectors.toList());
    }

    @Override
    public IntStream createIntStream(int start, int end) {
        return IntStream.rangeClosed(start, end);
    }

    @Override
    public DoubleStream squareRootIntStream(IntStream intStream) {
        return intStream.mapToDouble(Math::sqrt);
    }

    @Override
    public IntStream getOdd(IntStream intStream) {
        return intStream.filter(n -> n % 2 == 1);
    }

    @Override
    public Consumer<String> getLambdaPrinter(String prefix, String suffix) {
        return msg -> System.out.println(prefix + msg + suffix);
    }

    @Override
    public void printMessages(String[] messages, Consumer<String> printer) {
        Stream.of(messages).forEach(printer);
    }

    @Override
    public void printOdd(IntStream intStream, Consumer<String> printer) {
        getOdd(intStream).forEach(num -> printer.accept(String.valueOf(num)));
    }

    @Override
    public Stream<Integer> flatNestedInt(Stream<List<Integer>> ints) {
        return ints.flatMap(List::stream).map(num -> num * num);
    }
}
