// doubly linked node :sunglasses:

public class Node<T> {
    public T value;
    public Node next;
    public Node prev;

    public Node(T value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return value.toString();
    }
}