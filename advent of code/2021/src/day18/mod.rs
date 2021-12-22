use std::{
    cmp::max,
    collections::{HashMap, HashSet},
};

pub fn solve() {}

fn part_one() -> i64 {
    0
}

// struct InternalNode {
//         left: Box<BinaryTree>,
//         right: Box<BinaryTree>,
//         parent: Option<InternalNode>,
// }
// struct Leaf {
//     val: i64,
//     parent: InternalNode,
// }

#[derive(PartialEq)]
struct Internal {
    left: Box<BinaryTree>,
    right: Box<BinaryTree>,
    parent: Option<Box<Internal>>,
}
#[derive(PartialEq)]
struct Leaf {
    val: i64,
    parent: Box<Internal>,
}

#[derive(PartialEq)]
enum BinaryTree {
    Internal(Internal),
    Leaf(Leaf),
}

impl BinaryTree {
    pub fn reduce(&mut self) {
        let mut modified = true;
        while modified {
            modified = self.reduce_pass();
        }
    }

    fn reduce_pass(&mut self) -> bool {
        return self.explode_pass(1) || self.split_pass(1);
    }

    // Finds the leftmost 4-deep mode, and explodes it.
    fn explode_pass(&mut self, height: u32) -> bool {
        match self {
            BinaryTree::Leaf(Leaf { val: _, parent: _ }) => false,
            BinaryTree::Internal(Internal {
                left,
                right,
                parent: parent_box,
            }) => {
                if height < 4 {
                    return left.explode_pass(height + 1);
                }
                // Explode
                if let Some(boxed) = *parent_box {
                    let parent = *boxed;
                    let replacement = Box::new(BinaryTree::Leaf(Leaf {
                        val: 0,
                        parent: boxed,
                    }));
                    if *(parent.left) == *self {
                        parent.left = replacement;
                    } else {
                        parent.left = replacement;
                    }
                    return true;
                }
                panic!("Parent of an exploding node should always exist.");
            }
        }
    }

    fn get_left_cousin(&self) -> &mut Leaf {
        let mut curr = self;
        while curr != None {
            curr == curr
        }

        todo!("");
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn part_1() {
        // assert_eq!(part_one(-10, -5), 45);
    }

    // #[test]
    // fn part_2() {
    //     // target area: x=20..30, y=-10..-5
    //     assert_eq!(part_two(20, 30, -10, -5), 112);
    // }
}
