use std::{cell::RefCell, fmt, rc::Rc};

pub fn solve() {
    println!("Part 1: {}", part_one(include_str!("./input.txt")));
    println!("Part 2: {}", part_two(include_str!("./input.txt")));
}

fn part_one(contents: &str) -> usize {
    let nums: Vec<&str> = contents.split("\n").collect();
    let sum = nums
        .iter()
        .skip(1)
        .fold(parse(nums[0]), |acc, &item| add(acc, parse(item)));
    magnitude(&sum)
}

fn part_two(contents: &str) -> usize {
    let nums: Vec<&str> = contents.split("\n").collect();
    let mut max: usize = 0;
    for (i1, &x) in nums.iter().enumerate() {
        for (i2, &y) in nums.iter().enumerate() {
            if i1 == i2 {
                continue;
            }
            max = usize::max(max, magnitude(&add(parse(x), parse(y))));
        }
    }
    max
}

#[derive(PartialEq)]
struct Tree {
    root: Rc<RefCell<Value>>,
}

#[derive(PartialEq)]
struct InternalNode {
    parent: Option<Rc<RefCell<Value>>>,
    left: Rc<RefCell<Value>>,
    right: Rc<RefCell<Value>>,
}

#[derive(PartialEq)]
struct LeafNode {
    parent: Option<Rc<RefCell<Value>>>,
    val: usize,
}

fn wrap(v: Value) -> Rc<RefCell<Value>> {
    Rc::new(RefCell::new(v))
}

#[derive(PartialEq)]
enum Value {
    Leaf(LeafNode),
    Internal(InternalNode),
}

impl fmt::Debug for InternalNode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let left = &self.left.borrow();
        let right = &self.right.borrow();
        write!(f, "[{:?},{:?}]", left, right)
    }
}
impl fmt::Debug for LeafNode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", &self.val)
    }
}

impl fmt::Debug for Tree {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let root = &*&self.root.borrow();
        write!(f, "{:?}", root)
    }
}

impl fmt::Debug for Value {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match &self {
            Value::Leaf(node) => write!(f, "{:?}", node),
            Value::Internal(node) => write!(f, "{:?}", node),
        }
    }
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
        Value::Internal(parent_node) => {
            if Rc::ptr_eq(&parent_node.left, &node) {
                return get_prev(Some(parent.clone()));
            }
            // Now traverse to the rightmost child.
            let mut curr = parent_node.left.clone();
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
        Value::Internal(parent_node) => {
            if Rc::ptr_eq(&parent_node.right, &node) {
                return get_next(Some(parent.clone()));
            }
            // Now traverse to the leftmost child.
            let mut curr = parent_node.right.clone();
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
    if let Value::Internal(internal) = &*node.borrow() {
        return split(internal.left.clone()) || split(internal.right.clone());
    }
    let new_node = if let Value::Leaf(leaf) = &*node.borrow() {
        if leaf.val < 10 {
            None
        } else {
            let new_left_node = Value::Leaf(LeafNode {
                parent: Some(node.clone()),
                val: leaf.val / 2,
            });
            let new_right_node = Value::Leaf(LeafNode {
                parent: Some(node.clone()),
                val: leaf.val / 2 + leaf.val % 2,
            });
            Some(Value::Internal(InternalNode {
                left: wrap(new_left_node),
                right: wrap(new_right_node),
                parent: leaf.parent.clone(),
            }))
        }
    } else {
        unreachable!();
    };
    if new_node.is_none() {
        return false;
    }
    node.replace(new_node.unwrap());
    true
}

fn explode(value: Rc<RefCell<Value>>, depth: usize) -> bool {
    let new_node = match &*value.borrow() {
        Value::Leaf(_) => None,
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
            Some(Value::Leaf(LeafNode {
                parent: node.parent.clone(),
                val: 0,
            }))
        }
    };
    if new_node.is_none() {
        return false;
    }
    value.replace(new_node.unwrap());
    true
}

#[cfg(test)]
mod tests {
    use super::*;

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
        let sum = add(a, b);
        assert_eq!(magnitude(&sum), 129);
    }

    #[test]
    fn add_with_reduce() {
        let nums: Vec<Tree> = vec!["[1,1]", "[2,2]", "[3,3]", "[4,4]"]
            .iter()
            .map(|&num| parse(num))
            .collect();
        let sum = nums.into_iter().reduce(|acc, item| add(acc, item)).unwrap();
        assert_eq!(format!("{:?}", sum), "[[[[1,1],[2,2]],[3,3]],[4,4]]");

        let nums: Vec<Tree> = vec!["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]", "[6,6]"]
            .iter()
            .map(|&num| parse(num))
            .collect();
        let sum = nums.into_iter().reduce(|acc, item| add(acc, item)).unwrap();
        assert_eq!(format!("{:?}", sum), "[[[[5,0],[7,4]],[5,5]],[6,6]]");

        let nums: Vec<Tree> = vec!["[[[[4,3],4],4],[7,[[8,4],9]]]", "[1,1]"]
            .iter()
            .map(|&num| parse(num))
            .collect();
        let sum = nums.into_iter().reduce(|acc, item| add(acc, item)).unwrap();
        assert_eq!(format!("{:?}", sum), "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]");

        let nums: Vec<Tree> = "[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]"
            .split("\n")
            .map(|num| parse(num))
            .collect();
        let sum = nums.into_iter().reduce(|acc, item| add(acc, item)).unwrap();
        assert_eq!(
            format!("{:?}", sum),
            "[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]"
        );
    }

    #[test]
    fn part_one_example() {
        assert_eq!(part_one(include_str!("./example.txt")), 4140);
    }

    #[test]
    fn part_two_example() {
        assert_eq!(part_two(include_str!("./example.txt")), 3993);
    }
}
