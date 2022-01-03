use std::{borrow::BorrowMut, cell::RefCell, rc::Rc};

pub fn solve() {
    part_one();
}

fn part_one() -> i64 {
    42
}

#[derive(PartialEq, Debug)]
struct Tree {
    root: Node,
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
    // let parsed = parse_next(input).0;
    // Tree { root: parse_next(input).0 }
    match parse_next(input).0 {
        Value::Internal(root) => Tree { root },
        _ => unreachable!(),
    }
}

fn parse_next<'a>(input: &'a str) -> (Rc<RefCell<Value>>, &'a str) {
    if input.starts_with("]") || input.starts_with(",") {
        return parse_next(&input[1..], parent);
    }

    if input.starts_with("[") {
        let mut node = Node {
            left: wrap(Value::Leaf(0)),
            right: wrap(Value::Leaf(0)),
            parent: wrap(Value::Leaf(0)),
        };
        let (left, remainder) = parse_next(&input[1..]);
        let (right, remainder) = parse_next(remainder);
        let borrowed_left = left.borrow_mut();
        // node.left = wrap(left);
        // node.right = wrap(right);
        return (Value::Internal(node), remainder);
        todo!()
    }
    let val = Value::Leaf(input.chars().next().unwrap().to_digit(10).unwrap() as usize);
    return (val, &input[1..]);
}

fn assign_parent(v: &mut Value, p: &Node) {
    match v {
        Value::Internal(node) => node.parent = wrap(Value::Internal(p)),
        _ => unreachable!(),
    };
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn is_anything_running() {
        assert_eq!(part_one(), 42);
    }

    // #[test]
    // fn parse_easy() {
    //     let input = "[1,2]";
    //     let parsed = parse(input);
    //     let expected = Tree {
    //         root: Node {
    //             left: wrap(Value::Leaf(1)),
    //             right: wrap(Value::Leaf(2)),
    //         },
    //     };
    //     assert_eq!(parsed, expected);
    // }

    // #[test]
    // fn holds_shit() {
    //     let tree = Tree {
    //         root: Node {
    //             left: Value::Leaf(1),
    //             right: Value::Leaf(2),
    //         },
    //     };
    //     let left = tree.root.left;
    //     let right = tree.root.right;
    //     match (left, right) {
    //         (Value::Leaf(n1), Value::Leaf(n2)) => {
    //             assert_eq!(n1, 1);
    //             assert_eq!(n2, 2);
    //         }
    //         _ => unreachable!(),
    //     }
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
