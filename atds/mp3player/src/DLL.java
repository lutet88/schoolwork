public class DLL<T> {
    private Node<T> first;
    private Node<T> last;
    public int length;

    public DLL() {
        first = null;
        last = null;
        length = 0;
    }

    // precondition: start and end are connected through .next from start
    public DLL(Node<T> start, Node<T> end) {
        first = start;
        last = end;
        length = 1;
        Node<T> n = start;
        while (n.next != null) {
            length ++;
            n = n.next;
        }
    }

    public int count() {
        return length;
    }

    public void set(int index, T value) {
        if (length == 0) return;
        getNode(index).value = value;
    }

    public Node<T> getNode(int index) {
        if (length == 0) return null;
        Node<T> node = first;
        for (int i = 0; i < index; i++) {
            node = node.next;
        }
        return node;
    }

    public Node<T> getFirst() {
        return first;
    }

    public Node<T> getLast() {
        return last;
    }

    public T get(int index) {
        if (length == 0) return null;
        return getNode(index).value;
    }

    private void createFirst(T value) {
        assert length == 0;
        first = new Node<T>(value);
        last = first;
        length = 1;
    }

    private void createFirst(Node<T> node) {
        assert length == 0;
        first = node;
        last = first;
        length = 1;
    }

    public Node<T> appendLast(T value) {
        if (length == 0) {
            createFirst(value);
            return first;
        }
        last.next = new Node<T>(value);
        last.next.prev = last;
        last = last.next;
        length ++;
        return last;
    }

    public Node<T> appendLast(Node<T> node) {
        if (length == 0) {
            createFirst(node);
            return first;
        }
        last.next = node;
        last.next.prev = last;
        last = last.next;
        length ++;
        return last;
    }

    public Node<T> appendFirst(T value) {
        if (length == 0) {
            createFirst(value);
            return first;
        }
        first.prev = new Node<T>(value);
        first.prev.next = first;
        first = first.prev;
        length ++;
        return first;
    }

    public Node<T> appendFirst(Node<T> node) {
        if (length == 0) {
            createFirst(node);
            return first;
        }
        first.prev = node;
        first.prev.next = first;
        first = first.prev;
        length ++;
        return first;
    }

    public Node<T> popLast() {
        if (length == 0) return null;
        last = last.prev;
        last.next.prev = null;
        Node<T> temp = last.next;
        last.next = null;
        length --;
        return temp;
    }

    public Node<T> popFirst() {
        if (length == 0) return null;
        first = first.next;
        first.prev.next = null;
        Node<T> temp = first.prev;
        first.prev = null;
        length --;
        return temp;
    }

    public Node<T> popSecond() {
        return pop(1);
    }

    public Node<T> pop(int index) {
        if (length == 0) return null;
        Node<T> n = getNode(index);
        if(n.prev != null) n.prev.next = n.next;
        if(n.next != null) n.next.prev = n.prev;
        if(n == first) first = n.next;
        if(n == last) last = n.prev;
        n.next = null;
        n.prev = null;
        length --;
        return n;
    }

    public Node<T> pop(Node<T> n) {
        if (length == 0) return null;
        if(n.prev != null) n.prev.next = n.next;
        if(n.next != null) n.next.prev = n.prev;
        if(n == first) first = n.next;
        if(n == last) last = n.prev;
        n.next = null;
        n.prev = null;
        length --;
        return n;
    }

    public void insertAfter(int index, T value) {
        if (length == 0) {
            createFirst(value);
        }
        Node<T> n = getNode(index);
        Node<T> newNode = new Node<>(value);
        n.next.prev = newNode;
        newNode.prev = n;
        newNode.next = n.next;
        n.next = newNode;
        length ++;
    }

    public void insertBefore(int index, T value) {
        if (length == 0) {
            createFirst(value);
        }
        Node<T> n = getNode(index);
        Node<T> newNode = new Node<>(value);
        n.prev.next = newNode;
        newNode.prev = n.prev;
        n.prev = newNode;
        newNode.next = n;
        length ++;
    }

    public boolean has(T value) {
        Node<T> n = first;
        while (n.next != null) {
            if (n.value.equals(value)) return true;
            n = n.next;
        }
        if (n.value == value) return true;
        return false;
    }

    public Node<T> getNodeFromValue(T value) {
        Node<T> n = first;
        while (n.next != null) {
            if (n.value == value) return n;
            n = n.next;
        }
        if (n.value == value) return n;
        return null;
    }

    public static <T> Node<T> copyNode(Node<T> n) {
        return new Node<T>(n.value);
    }

    public static <T> DLL<T> copyList(DLL<T> ll) {
        DLL<T> ll2 = new DLL<T>();
        ll2.set(0, ll.get(0));
        Node<T> n = ll.getNode(0);
        while (n.next != null) {
            n = n.next;
            ll2.appendLast(n.value);
        }
        return ll2;
    }

    public static <T> DLL<T> copyList(DLL<T> ll, int start, int end) {
        return copyList(ll.getNode(start), ll.getNode(end));
    }

    // end is not inclusive!
    public static <T> DLL<T> copyList(Node<T> start, Node<T> end) {
        DLL<T> ll2 = new DLL<T>();
        ll2.set(0, start.value);
        Node<T> n = start;
        while (n.next != null && n.next != end) {
            n = n.next;
            ll2.appendLast(n.value);
        }
        return ll2;
    }

    // returns two LinkedLists, first one including Node split, second one starting from split.next
    public static <T> DLL<T>[] split(DLL<T> ll, Node<T> split) {
        DLL<T> ll1 = copyList(ll.getFirst(), split);
        DLL<T> ll2 = copyList(split, null);
        // why does java make me do this !!!! >:(
        DLL<T>[] out = (DLL<T>[]) java.lang.reflect.Array.newInstance(ll1.getClass().getComponentType(), 2);
        out[0] = ll1;
        out[1] = ll2;
        return out;
    }

    public static <T> DLL<T> concatCopy(DLL<T> ll1, DLL<T> ll2) {
        DLL<T> ll = new DLL<T>();
        Node<T> n = ll1.getFirst();
        while (n.next != null) {
            ll.appendLast(n.value);
            n = n.next;
        }
        n = ll2.getFirst();
        while (n.next != null) {
            ll.appendLast(n.value);
            n = n.next;
        }
        return ll;
    }

    // adds ll2 to end of ll
    public void concat(DLL<T> ll2) {
        Node<T> tempLast = last;
        last = ll2.getLast();
        tempLast.next = ll2.getFirst();
        tempLast.next.prev = tempLast;
        length += ll2.length;
    }

    public static <T> DLL<T> reversed(DLL<T> ll) {
        DLL<T> out = new DLL<T>();
        for (int i = ll.length-1; i >= 0; i--) {
            out.appendLast(ll.getNode(i).value);
        }
        return out;
    }

    public void reverse() {
        for (int i = length-1; i >= 0; i--) {
            Node<T> n = pop(last.prev);
            appendLast(n.value);
        }
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("LL[");
        Node n = first;
        while (n != null) {
            sb.append(n.value);
            n = n.next;
            if (n != null) sb.append(", ");
        }
        sb.append("], len=");
        sb.append(length);
        return sb.toString();
    }
}