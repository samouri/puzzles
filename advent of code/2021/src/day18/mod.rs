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
struct InternalNode {
    parent: Option<Rc<RefCell<Value>>>,
    left: Rc<RefCell<Value>>,
    right: Rc<RefCell<Value>>,
}

#[derive(PartialEq, Debug)]
struct LeafNode {
    parent: Option<Rc<RefCell<Value>>>,
    val: usize,
}

fn wrap(v: Value) -> Rc<RefCell<Value>> {
    Rc::new(RefCell::new(v))
}

#[derive(PartialEq, Debug)]
enum Value {
    Leaf(LeafNode),
    Internal(InternalNode),
}

// Parse only returns the first snailfish number found in the str
fn parse(input: &str) -> Tree {
    let root = wrap(parse_next(input).0);
    assign_parents(Rc::clone(&root), None);
    Tree { root }
}

fn parse_next<'a>(input: &'a str) -> (Value, &'a str) {
    if input.starts_with("]") || input.starts_with(",") {
        return parse_next(&input[1..]);
    }

    if input.starts_with("[") {
        let (left, remainder) = parse_next(&input[1..]);
        let (right, remainder) = parse_next(remainder);
        let node = InternalNode {
            left: wrap(left),
            right: wrap(right),
            parent: None,
        };
        return (Value::Internal(node), remainder);
    }
    let val = input.chars().next().unwrap().to_digit(10).unwrap() as usize;
    let val = Value::Leaf(LeafNode { val, parent: None });
    return (val, &input[1..]);
}

fn assign_parents(v: Rc<RefCell<Value>>, parent: Option<Rc<RefCell<Value>>>) {
    match &mut *v.borrow_mut() {
        Value::Leaf(node) => node.parent = parent,
        Value::Internal(node) => {
            node.parent = parent;
            assign_parents(Rc::clone(&node.left), Some(Rc::clone(&v)));
            assign_parents(Rc::clone(&node.right), Some(Rc::clone(&v)));
        }
    };
}

fn magnitude(tree: &Tree) -> usize {
    magnitude_helper(Rc::clone(&tree.root))
}
fn magnitude_helper(tree_val: Rc<RefCell<Value>>) -> usize {
    match &*tree_val.borrow() {
        Value::Leaf(v) => v.val,
        Value::Internal(node) => {
            return 3 * magnitude_helper(Rc::clone(&node.left))
                + 2 * magnitude_helper(Rc::clone(&node.right));
        }
    }
}

fn reduce(t: Tree) -> Tree {
    while explode(t.root.clone(), 0) || split(t.root.clone()) {}
    t
}

fn add(a: Tree, b: Tree) -> Tree {
    let root = wrap(Value::Internal(InternalNode {
        parent: None,
        left: a.root,
        right: b.root,
    }));

    match &*root.borrow() {
        Value::Internal(r) => {
            let left = &mut *r.left.borrow_mut();
            match left {
                Value::Internal(l) => l.parent = Some(Rc::clone(&root)),
                _ => unreachable!(),
            }
            let right = &mut *r.right.borrow_mut();
            match right {
                Value::Internal(r) => r.parent = Some(Rc::clone(&root)),
                _ => unreachable!(),
            }
        }
        _ => unreachable!(),
    }

    reduce(Tree {
        root: Rc::clone(&root),
    })
}

fn get_prev(node: Option<Rc<RefCell<Value>>>) -> Option<Rc<RefCell<Value>>> {
    let node = node?;
    let parent = match &*node.borrow() {
        Value::Leaf(node) => node.parent.clone(),
        Value::Internal(node) => node.parent.clone(),
    }?;
    let pval: &Value = &*parent.borrow();
    match pval {
        Value::Leaf(_) => unreachable!(),
        Value::Internal(parent) => {
            if Rc::ptr_eq(&parent.left, &node) {
                return get_prev(parent.parent.clone());
            }
            // Now traverse to the rightmost child.
            let mut curr = parent.left.clone();
            loop {
                match &*Rc::clone(&curr).borrow() {
                    Value::Leaf(_) => return Some(curr),
                    Value::Internal(node) => curr = node.right.clone(),
                };
            }
        }
    }
}

fn get_next(node: Option<Rc<RefCell<Value>>>) -> Option<Rc<RefCell<Value>>> {
    let node = node?;
    let parent = match &*node.borrow() {
        Value::Leaf(node) => node.parent.clone(),
        Value::Internal(node) => node.parent.clone(),
    }?;
    let pval: &Value = &*parent.borrow();
    match pval {
        Value::Leaf(_) => unreachable!(),
        Value::Internal(parent) => {
            if Rc::ptr_eq(&parent.right, &node) {
                return get_next(parent.parent.clone());
            }
            // Now traverse to the leftmost child.
            let mut curr = parent.right.clone();
            loop {
                match &*Rc::clone(&curr).borrow() {
                    Value::Leaf(_) => return Some(curr),
                    Value::Internal(node) => curr = node.left.clone(),
                };
            }
        }
    }
}

// fn get_internal_mut<'a>(node: Rc<RefCell<Value>>) -> InternalNode {
//     match &*node.borrow_mut() {
//         Value::Leaf(_) => unreachable!(),
//         Value::Internal(node) => *node,
//     }
// }

fn split(node: Rc<RefCell<Value>>) -> bool {
    match &*node.borrow() {
        Value::Internal(internal) => {
            return split(internal.left.clone()) || split(internal.right.clone())
        }
        Value::Leaf(leaf) => {
            if leaf.val < 10 {
                return false;
            }
            let new_left_node = Value::Leaf(LeafNode {
                parent: None,
                val: leaf.val / 2,
            });
            let new_right_node = Value::Leaf(LeafNode {
                parent: None,
                val: leaf.val / 2 + leaf.val % 2,
            });
            match &*leaf.parent.as_ref().unwrap().borrow_mut() {
                Value::Internal(parent) => {
                    let new_this_node = Value::Internal(InternalNode {
                        left: wrap(new_left_node),
                        right: wrap(new_right_node),
                        parent: leaf.parent.clone(),
                    });
                    if Rc::ptr_eq(&parent.left, &node) {
                        parent.left.replace(new_this_node);
                    } else {
                        parent.right.replace(new_this_node);
                    }
                    assign_parents(leaf.parent.as_ref().unwrap().clone(), parent.parent.clone());
                }
                _ => unreachable!(),
            }
            return true;
        }
    }
}

fn explode(value: Rc<RefCell<Value>>, depth: usize) -> bool {
    match &*value.borrow() {
        Value::Leaf(_) => false,
        Value::Internal(node) => {
            if depth < 4 {
                return explode(Rc::clone(&node.left), depth + 1)
                    || explode(Rc::clone(&node.right), depth + 1);
            }
            let (left_val, right_val) = match (&*node.left.borrow(), &*node.right.borrow()) {
                (Value::Leaf(left_leaf), Value::Leaf(right_leaf)) => {
                    (left_leaf.val, right_leaf.val)
                }
                _ => unreachable!(),
            };
            let prev = get_prev(Some(value.clone()));
            if let Some(prev) = prev {
                if let Value::Leaf(leaf_node) = &mut *prev.borrow_mut() {
                    leaf_node.val += left_val
                }
            };
            let next = get_next(Some(value.clone()));
            if let Some(next) = next {
                if let Value::Leaf(leaf_node) = &mut *next.borrow_mut() {
                    leaf_node.val += right_val
                }
            };
            match &*node.parent.as_ref().unwrap().borrow() {
                Value::Internal(p) => {
                    let new_node = Value::Leaf(LeafNode {
                        parent: node.parent.clone(),
                        val: 0,
                    });
                    if Rc::ptr_eq(&p.left, &value) {
                        p.left.replace(new_node);
                    } else {
                        p.right.replace(new_node);
                    }
                }
                _ => unreachable!(),
            }
            true
        }
    }
}

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
        if let Value::Internal(root) = &*parsed.root.borrow() {
            match &*root.left.borrow() {
                Value::Leaf(node) => {
                    assert_eq!(node.val, 1);
                }
                _ => unreachable!(),
            }
            match &*root.right.borrow() {
                Value::Leaf(node) => {
                    assert_eq!(node.val, 2);
                }
                _ => unreachable!(),
            }
            return;
        }
        unreachable!()
    }

    #[test]
    fn prev() {
        let input = "[1,2]";
        let parsed = parse(input);
        if let Value::Internal(root) = &*parsed.root.borrow() {
            let prev = get_prev(Some(root.right.clone())).unwrap();
            match &*prev.borrow() {
                Value::Leaf(node) => {
                    assert_eq!(node.val, 1);
                }
                _ => unreachable!(),
            }
            return;
        }
        unreachable!()
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

    #[test]
    fn add_with_reduce() {
        let a = parse("[[[[4,3],4],4],[7,[[8,4],9]]]");
        let b = parse("[1,1]");
        assert_eq!(magnitude(&add(a, b)), 129);
    }
}
