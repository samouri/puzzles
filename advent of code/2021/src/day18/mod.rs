use std::{cell::RefCell, rc::Rc};

pub fn solve() {
    part_one();
}

fn part_one() -> i64 {
    42
}

#[derive(PartialEq, Debug)]
struct Tree {
    root: Rc<RefCell<Value>>,
}

#[derive(PartialEq, Debug)]
struct Node {
    parent: Rc<RefCell<Value>>,
    left: Rc<RefCell<Value>>,
    right: Rc<RefCell<Value>>,
}

fn wrap(v: Value) -> Rc<RefCell<Value>> {
    Rc::new(RefCell::new(v))
}

#[derive(PartialEq, Debug)]
enum Value {
    Leaf(usize),
    Internal(Node),
}

// Parse only returns the first snailfish number found in the str
fn parse(input: &str) -> Tree {
    let root = wrap(parse_next(input).0);
    assign_parents(Rc::clone(&root), wrap(Value::Leaf(0)));
    Tree { root }
}

fn parse_next<'a>(input: &'a str) -> (Value, &'a str) {
    if input.starts_with("]") || input.starts_with(",") {
        return parse_next(&input[1..]);
    }

    if input.starts_with("[") {
        let (left, remainder) = parse_next(&input[1..]);
        let (right, remainder) = parse_next(remainder);
        let node = Node {
            left: wrap(left),
            right: wrap(right),
            parent: wrap(Value::Leaf(0)),
        };
        return (Value::Internal(node), remainder);
    }
    let val = Value::Leaf(input.chars().next().unwrap().to_digit(10).unwrap() as usize);
    return (val, &input[1..]);
}

fn assign_parents(v: Rc<RefCell<Value>>, parent: Rc<RefCell<Value>>) {
    let derefed = &mut *v.borrow_mut();

    match derefed {
        Value::Internal(node) => {
            node.parent = parent;
            assign_parents(Rc::clone(&node.left), Rc::clone(&v));
            assign_parents(Rc::clone(&node.right), Rc::clone(&v));
        }
        Value::Leaf(_) => {}
    };
}

fn magnitude(tree: &Tree) -> usize {
    magnitude_helper(Rc::clone(&tree.root))
}
fn magnitude_helper(tree_val: Rc<RefCell<Value>>) -> usize {
    match &*tree_val.borrow() {
        Value::Leaf(v) => *v,
        Value::Internal(node) => {
            return 3 * magnitude_helper(Rc::clone(&node.left))
                + 2 * magnitude_helper(Rc::clone(&node.right));
        }
    }
}

fn add(a: Tree, b: Tree) -> Tree {
    let root = wrap(Value::Internal(Node {
        parent: wrap(Value::Leaf(0)),
        left: a.root,
        right: b.root,
    }));

    let parent: &mut Value = &mut *root.borrow_mut();
    match parent {
        Value::Internal(r) => {
            let left = &mut *r.left.borrow_mut();
            match left {
                Value::Internal(l) => l.parent = Rc::clone(&root),
                _ => unreachable!(),
            }
            let right = &mut *r.right.borrow_mut();
            match right {
                Value::Internal(r) => r.parent = Rc::clone(&root),
                _ => unreachable!(),
            }
        }
        _ => unreachable!(),
    }

    Tree {
        root: Rc::clone(&root),
    }
}

fn explode(value: Rc<RefCell<Value>>, depth: usize) -> bool {
    match &*value.borrow_mut() {
        Value::Internal(node) => {
            if (depth >= 4) {
                // let left_val = match &*node.left.borrow() {

                // } ;
                match &*node.parent.borrow_mut() {
                    Value::Internal(p) => {
                        if p.left == value {
                            p.left.replace(Value::Leaf(0));
                        } else {
                            p.right.replace(Value::Leaf(0));
                        }
                    }
                    _ => panic!(),
                }
                true
            } else {
                explode(Rc::clone(&node.left), depth + 1)
                    || explode(Rc::clone(&node.right), depth + 1)
            }
        }
        _ => false,
    }
}

// is the value an internal node with 2 leafs
// fn is_pair(value: Rc<RefCell<Value>>) -> bool {
//     match &*value.borrow() {
//         Value::Internal(node) => match &*node.left.borrow() {
//             Value::Internal(_) => false,
//             Value::Leaf(_) => match &*node.right.borrow() {
//                 Value::Internal(_) => false,
//                 Value::Leaf(_) => true,
//             },
//         },
//         _ => panic!(),
//     }
// }

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn is_anything_running() {
        assert_eq!(part_one(), 42);
    }

    #[test]
    fn parse_easy() {
        let input = "[1,2]";
        let parsed = parse(input);
        let expected = Tree {
            root: wrap(Value::Internal(Node {
                left: wrap(Value::Leaf(1)),
                right: wrap(Value::Leaf(2)),
                parent: wrap(Value::Leaf(0)),
            })),
        };
        assert_eq!(parsed, expected);
    }

    #[test]
    fn magnitude_easy() {
        let input = "[[9,1],[1,9]]";
        assert_eq!(magnitude(&parse(input)), 129);

        let input = "[[1,1],1]";
        assert_eq!(magnitude(&parse(input)), 17);
    }

    #[test]
    fn add_no_reduce() {
        let a = parse("[9,1]");
        let b = parse("[1,9]");

        assert_eq!(magnitude(&add(a, b)), 129);
    }

    // #[test]
    // fn get_suc() {
    //     let a = parse("[[1,2],[3,4]]");
    //     let two = match &*a.root.borrow() {
    //         Value::Internal(root_node) => {
    //             match &*root_node.left.borrow() {
    //                 Value::Internal(left_node) => {
    //                     match &*left_node.right.borrow() {

    //                     }
    //                 },
    //                 _ => unreachable!()
    //             }
    //         },
    //         _ => unreachable!()
    //     };
    // }
}

// #[derive(PartialEq, Debug)]
// struct Node {
//     val: Option<i64>,
//     parent: Option<Rc<RefCell<Node>>>,
//     left: Option<Rc<RefCell<Node>>>,
//     right: Option<Rc<RefCell<Node>>>,
// }

// impl Node {
//     fn is_leaf(&self) -> bool {
//         self.val.is_some()
//     }
//     fn is_internal(&self) -> bool {
//         self.left.is_some()
//     }

//     pub fn reduce(&mut self) {
//         while self.reduce_pass() {}
//     }

//     fn reduce_pass(&mut self) -> bool {
//         return self.explode_pass(1, None) || self.split_pass(None);
//     }

//     // Finds the leftmost 4-deep node, and explodes it.
//     fn explode_pass(&mut self, height: u32, ref_self: Option<Rc<RefCell<Node>>>) -> bool {
//         if self.is_leaf() {
//             return false;
//         }
//         if height < 4 {
//             let left = &mut self.left.unwrap().borrow_mut();
//             let right = &self.right.unwrap().borrow_mut();
//             return left.explode_pass(height + 1, self.left.clone())
//                 || right.explode_pass(height + 1, self.right.clone());
//         }

//         // First add the snail values to either side.
//         if let Some(left_cousin) = self.get_left_cousin(ref_self.clone()) {
//             let node = *(*left_cousin).borrow();
//             let val = node.val.unwrap();
//             node.val.replace(val + self.val.unwrap());
//         }
//         if let Some(right_cousin) = self.get_right_cousin(ref_self.clone()) {
//             let node = *(*right_cousin).borrow();
//             let val = node.val.unwrap();
//             node.val.replace(val + self.val.unwrap());
//         }

//         // Finally replace current spot with 0.
//         self.val = Some(0);
//         self.left = None;
//         self.right = None;
//         true
//     }

//     fn new(val: Option<i64>, parent: Option<Rc<RefCell<Node>>>) -> Rc<RefCell<Self>> {
//         Rc::new(RefCell::new(Self {
//             val,
//             left: None,
//             right: None,
//             parent,
//         }))
//     }

//     fn split_pass(&mut self, ref_self: Option<Rc<RefCell<Node>>>) -> bool {
//         if self.is_internal() {
//             let left: Node = *(*self.left.unwrap()).borrow();
//             let right: Node = *(*self.right.unwrap()).borrow();
//             return left.split_pass(self.left.clone()) || right.split_pass(self.right.clone());
//         }
//         if self.val.unwrap() < 10 {
//             return false;
//         }
//         let val = self.val.unwrap();
//         let new_left_node = Node::new(Some(val / 2), ref_self.clone());
//         let new_right_node = Node::new(Some(val / 2 + val % 2), ref_self.clone());
//         self.left = Some(new_left_node);
//         self.right = Some(new_right_node);
//         self.val = None;
//         true
//     }

//     fn get_left_cousin(&self, ref_self: Option<Rc<RefCell<Node>>>) -> Option<Rc<RefCell<Node>>> {
//         match &self.parent {
//             None => None,
//             Some(boxed_parent) => {
//                 let parent = (**boxed_parent).borrow();
//                 if parent.left == ref_self {
//                     return parent.get_left_cousin(parent.left.clone());
//                 }
//                 // Now traverse to the rightmost child.
//                 let mut curr = parent.left.clone();
//                 loop {
//                     let next = (*(*curr.unwrap()).borrow()).right;
//                     if next.is_none() {
//                         return curr;
//                     }
//                     curr = next;
//                 }
//             }
//         }
//     }

//     fn get_right_cousin(&self, ref_self: Option<Rc<RefCell<Node>>>) -> Option<Rc<RefCell<Node>>> {
//         match self.parent {
//             None => None,
//             Some(boxed_parent) => {
//                 let parent = *(*boxed_parent).borrow();
//                 if parent.right == ref_self {
//                     return parent.get_right_cousin(parent.right.clone());
//                 }
//                 // Now traverse to the leftmost child.
//                 let mut curr = parent.right.clone();
//                 loop {
//                     let next = (*(*curr.unwrap()).borrow()).left;
//                     if next.is_none() {
//                         return curr;
//                     }
//                     curr = next;
//                 }
//             }
//         }
//     }
//     fn parse(input: &str) -> Node {
//         todo!("");
//         // Node {}
//         // for c in input.chars() {}
//     }
// }

// #[cfg(test)]
// mod tests {
//     use std::borrow::BorrowMut;

//     use super::*;

//     #[test]
//     fn part_1() {
//         // = assert_eq!(part_one(-10, -5), 45);
//     }

//     // #[test]
//     // fn part_2() {
//     //     // target area: x=20..30, y=-10..-5
//     //     assert_eq!(part_two(20, 30, -10, -5), 112);
//     // }
// }
