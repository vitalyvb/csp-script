//@ main

function x()
{
    return _nargs();
}

function main()
{
    e = _nargs();
    t = _nargs();
    return _addx(t, e, x());
}

