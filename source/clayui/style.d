module clayui.style;

class Style
{
    // rgba packed
    private ulong color;
    // l r t b packed
    private ulong padding;

    private Style setColor(ushort r, ushort g, ushort b, ushort a)
    {
        color = (cast(ulong)r << 48) |
                (cast(ulong)g << 32) |
                (cast(ulong)b << 16) |
                (cast(ulong)a);
        return this;
    }

    public ushort red()
    {
        return cast(ushort)((color>>48)&0xFFFF);
    }

    public ushort green()
    {
        return cast(ushort)((color>>32)&0xFFFF);
    }

    public ushort blue()
    {
        return cast(ushort)((color>>16)&0xFFFF);
    }

    public ushort alpha()
    {
        return cast(ushort)((color)&0xFFFF);
    }

    private Style setPadding(ushort l, ushort r, ushort t, ushort b)
    {
        padding = (cast(ulong)l << 48) |
                  (cast(ulong)r << 32) |
                  (cast(ulong)t << 16) |
                  (cast(ulong)b);
        return this;
    }

    public ushort paddingRight()
    {
        return cast(ushort)((padding>>48)&0xFFFF);
    }

    public ushort paddingLeft()
    {
        return cast(ushort)((padding>>32)&0xFFFF);
    }

    public ushort paddingTop()
    {
        return cast(ushort)((padding>>16)&0xFFFF);
    }

    public ushort paddingBottom()
    {
        return cast(ushort)((padding)&0xFFFF);
    }
}

unittest
{
    Style s = new Style();

    s.setPadding(1, 2, 3, 4);
    assert(s.paddingRight()  == 1);
    assert(s.paddingLeft()   == 2);
    assert(s.paddingTop()    == 3);
    assert(s.paddingBottom() == 4);

    s.setColor(1, 2, 3, 4);
    assert(s.red()   == 1);
    assert(s.green() == 2);
    assert(s.blue()  == 3);
    assert(s.alpha() == 4);
}