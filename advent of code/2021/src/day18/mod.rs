use std::{cell::RefCell, rc::Rc};

pub fn solve() {
    part_one();
}

fn part_one() -> i64 {
    // let mut nine = Node::new(Some(15), None);
    // let mut eight = Node::new(Some(9), None);
    // let lp = Node::new(None, None);
    // let mut lp_borrow = (*lp).borrow_mut();
    // lp_borrow.left = Some(nine);
    // lp_borrow.right = Some(nine);
    // lp_borrow.reduce();
    // println!("{:?}", lp_borrow);
    0
}

#[derive(PartialEq, Debug)]
struct Node {
    val: Option<i64>,
    parent: Option<Rc<RefCell<Node>>>,
    left: Option<Rc<RefCell<Node>>>,
    right: Option<Rc<RefCell<Node>>>,
}

impl Node {
    fn is_leaf(&self) -> bool {
        self.val.is_some()
    }
    fn is_internal(&self) -> bool {
        self.left.is_some()
    }

    pub fn reduce(&mut self) {
        while self.reduce_pass() {}
    }

    fn reduce_pass(&mut self) -> bool {
        return self.explode_pass(1, None) || self.split_pass(None);
    }

    // Finds the leftmost 4-deep node, and explodes it.
    fn explode_pass(&mut self, height: u32, ref_self: Option<Rc<RefCell<Node>>>) -> bool {
        if self.is_leaf() {
            return false;
        }
        if height < 4 {
            let left = &mut self.left.unwrap().borrow_mut();
            let right = &self.right.unwrap().borrow_mut();
            return left.explode_pass(height + 1, self.left.clone())
                || right.explode_pass(height + 1, self.right.clone());
        }

        // First add the snail values to either side.
        if let Some(left_cousin) = self.get_left_cousin(ref_self.clone()) {
            let node = *(*left_cousin).borrow();
            let val = node.val.unwrap();
            node.val.replace(val + self.val.unwrap());
        }
        if let Some(right_cousin) = self.get_right_cousin(ref_self.clone()) {
            let node = *(*right_cousin).borrow();
            let val = node.val.unwrap();
            node.val.replace(val + self.val.unwrap());
        }

        // Finally replace current spot with 0.
        self.val = Some(0);
        self.left = None;
        self.right = None;
        true
    }

    fn new(val: Option<i64>, parent: Option<Rc<RefCell<Node>>>) -> Rc<RefCell<Self>> {
        Rc::new(RefCell::new(Self {
            val,
            left: None,
            right: None,
            parent,
        }))
    }

    fn split_pass(&mut self, ref_self: Option<Rc<RefCell<Node>>>) -> bool {
        if self.is_internal() {
            let left: Node = *(*self.left.unwrap()).borrow();
            let right: Node = *(*self.right.unwrap()).borrow();
            return left.split_pass(self.left.clone()) || right.split_pass(self.right.clone());
        }
        if self.val.unwrap() < 10 {
            return false;
        }
        let val = self.val.unwrap();
        let new_left_node = Node::new(Some(val / 2), ref_self.clone());
        let new_right_node = Node::new(Some(val / 2 + val % 2), ref_self.clone());
        self.left = Some(new_left_node);
        self.right = Some(new_right_node);
        self.val = None;
        true
    }

    fn get_left_cousin(&self, ref_self: Option<Rc<RefCell<Node>>>) -> Option<Rc<RefCell<Node>>> {
        match &self.parent {
            None => None,
            Some(boxed_parent) => {
                let parent = (**boxed_parent).borrow();
                if parent.left == ref_self {
                    return parent.get_left_cousin(parent.left.clone());
                }
                // Now traverse to the rightmost child.
                let mut curr = parent.left.clone();
                loop {
                    let next = (*(*curr.unwrap()).borrow()).right;
                    if next.is_none() {
                        return curr;
                    }
                    curr = next;
                }
            }
        }
    }

    fn get_right_cousin(&self, ref_self: Option<Rc<RefCell<Node>>>) -> Option<Rc<RefCell<Node>>> {
        match self.parent {
            None => None,
            Some(boxed_parent) => {
                let parent = *(*boxed_parent).borrow();
                if parent.right == ref_self {
                    return parent.get_right_cousin(parent.right.clone());
                }
                // Now traverse to the leftmost child.
                let mut curr = parent.right.clone();
                loop {
                    let next = (*(*curr.unwrap()).borrow()).left;
                    if next.is_none() {
                        return curr;
                    }
                    curr = next;
                }
            }
        }
    }
    fn parse(input: &str) -> Node {
        todo!("");
        // Node {}
        // for c in input.chars() {}
    }
}

#[cfg(test)]
mod tests {
    use std::borrow::BorrowMut;

    use super::*;

    #[test]
    fn part_1() {
        // = assert_eq!(part_one(-10, -5), 45);
    }

    // #[test]
    // fn part_2() {
    //     // target area: x=20..30, y=-10..-5
    //     assert_eq!(part_two(20, 30, -10, -5), 112);
    // }
}
