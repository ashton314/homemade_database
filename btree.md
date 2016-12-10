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

#### Leaf Nodes

I don't use the `thing2` slot to link to the next sibbling
node. Instead, I use the `next_leaf` property in the `Btree::Node`
object to set the sibbling.

*Caveat:* I set `next_leaf` during the splitting process, and I don't
check if the node I am splitting is a leaf node or an index
node. Hence, even index nodes have `next_leaf` set to their
sibbling. In the future this should be changed to save a little space.

#### Index Nodes

When inserting, I `shift` off `thing0`, and can then treat the index
node like an index node. (+I never should need to insert into the
front of an index node: this can make the tree really broad, but can
be fixed with coalescing the nodes.+ Just kidding. This is a bug I'm
working on as of 2016-12-09.) After I'm done the insert, I just
`unshift` `thing0` back into the node.


Author
------

Ashton Wiersdorf (https://github.com/ashton314)
