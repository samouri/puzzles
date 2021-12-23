pub fn solve() {}

fn part_one() -> i64 {
    0
}

#[derive(PartialEq)]
struct Node {
    val: Option<i64>,
    parent: Option<Box<Node>>,
    left: Option<Box<Node>>,
    right: Option<Box<Node>>,
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
        return self.explode_pass(1) || self.split_pass();
    }

    // Finds the leftmost 4-deep node, and explodes it.
    fn explode_pass(&mut self, height: u32) -> bool {
        if self.is_leaf() {
            return false;
        }
        if height < 4 {
            return (self.left.as_deref_mut().unwrap()).explode_pass(height + 1)
                || (self.right.as_deref_mut().unwrap().explode_pass(height + 1));
        }
        // Time to replace with 0 and add to either side.
        let replacement = Some(Box::new(Node {
            val: Some(0),
            left: None,
            right: None,
            parent: self.parent,
        }));
        if *self.parent.unwrap().left.unwrap() == *self {
            self.parent.unwrap().left = replacement;
        } else {
            self.parent.unwrap().right = replacement;
        }

        if let Some(left_cousin) = self.get_left_cousin() {
            let val = left_cousin.val.unwrap();
            left_cousin.val = Some(val + self.left.unwrap().val.unwrap());
        }
        if let Some(right_cousin) = self.get_right_cousin() {
            let val = right_cousin.val.unwrap();
            right_cousin.val = Some(val + self.right.unwrap().val.unwrap());
        }
        true
    }

    fn split_pass(&mut self) -> bool {
        if self.is_internal() {
            return self.left.as_deref_mut().unwrap().split_pass()
                || self.right.as_deref_mut().unwrap().split_pass();
        }
        if self.val.unwrap() < 10 {
            return false;
        }
        let val = self.val.unwrap();
        let new_left_node = Node {
            left: None,
            right: None,
            val: Some(val / 2),
            parent: Some(Box::new(*self)),
        };
        let new_right_node = Node {
            val: Some(val / 2 + val % 2),
            left: None,
            right: None,
            parent: Some(Box::new(*self)),
        };
        self.left = Some(Box::new(new_left_node));
        self.right = Some(Box::new(new_right_node));
        self.val = None;
        true
    }

    fn get_left_cousin(&self) -> Option<&Node> {
        match &self.parent {
            None => None,
            Some(boxed_parent) => {
                let parent = boxed_parent;
                if parent.left.as_deref().unwrap() == self {
                    return parent.get_left_cousin();
                }
                // Now traverse to the leftmost child.
                let mut curr = parent.left.as_deref().unwrap();
                while curr.right.is_some() {
                    curr = curr.right.as_deref().unwrap()
                }
                return Some(curr);
            }
        }
    }

    fn get_right_cousin(&self) -> Option<&Node> {
        match &self.parent {
            None => None,
            Some(boxed_parent) => {
                let parent = boxed_parent;
                if parent.right.as_deref().unwrap() == self {
                    return parent.get_right_cousin();
                }
                // Now traverse to the leftmost child.
                let mut curr = parent.right.as_deref().unwrap();
                while curr.left.is_some() {
                    curr = curr.left.as_deref().unwrap()
                }
                return Some(curr);
            }
        }
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
