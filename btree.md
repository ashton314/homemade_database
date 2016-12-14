B+ Tree
=======

This is how I made a B+ tree.

Node Implementation
-------------------

I don't know how "standard" (whatever that means) my implementation of
nodes is. I just did the thing that worked. Bear in mind, this is a
rough draft.

### Theory

There are some excellent tutorials on B+ Trees. I'll include some
links here. I've been using an old textbook I found in my house:

> _Database System Concepts_
> By Abraham Silberschatz & Henry F. Korth
> ISBN: 0-07-031086-6

Nodes look like this:

     [ .  a  .  b  . ]
       /     |      \
      /      |       \
    thing0  thing1  thing2

In a leaf node, `thing0` points to what is indexed by `a`. `thing2`
points to the next leaf node, if there is one.

In an index node, `thing0` points to a leaf or sub-tree, where all
values are less than `a`. `thing1` then points to all things greater
than or equal to `a`, and less than `b`, and `thing2` points to all
things greater than or equal to `b`.

### Praxis

I differentiate between leaf and index nodes (aka "branch nodes" here)
by setting the `leaf` property in the `Btree::Node` object.

I tried doing some fancy optimizations by splitting before inserting
the datum, but I this complicated things a *lot*. I now insert the
datum, then check if I need to split. This simplified structure solved
all the problems I was having before.

If the node is an index node, I move half_way+1..$#vals into the new
node, as opposed to half\_way..$#vals in a leaf node.


Author
------

Ashton Wiersdorf (https://github.com/ashton314)
