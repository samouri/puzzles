use std::{collections::HashMap, fs};

pub fn solve() {
    let path = "src/day13/input.txt";
    let file_content: String = fs::read_to_string(path).unwrap();

    let points: HashMap<(u32, u32), bool> = file_content
        .lines()
        .filter_map(|line| line.split_once(","))
        .map(|(x, y)| (x.parse().unwrap(), y.parse().unwrap()))
        .fold(HashMap::new(), |mut map, (x, y)| {
            map.insert((x, y), true);
            map
        });

    let folds: Vec<(&str, u32)> = file_content
        .lines()
        .filter_map(|line| line.trim_start_matches("fold along ").split_once("="))
        .map(|(axis, val)| (axis, val.parse().unwrap()))
        .collect();

    let part_1_fold = fold_paper(&points, folds[0]);
    println!(
        "Part 1: {}",
        part_1_fold.iter().filter(|(_pt, &marked)| marked).count()
    );

    let fully_folded = folds
        .iter()
        .fold(points, |acc, &fold| fold_paper(&acc, fold));
    for y in 0..11 {
        for x in 0..40 {
            let c = if fully_folded.contains_key(&(x, y)) {
                "#"
            } else {
                "."
            };
            print!("{}", c);
        }
        print!("\n");
    }
}

fn fold_paper(points: &HashMap<(u32, u32), bool>, fold: (&str, u32)) -> HashMap<(u32, u32), bool> {
    let mut folded: HashMap<(u32, u32), bool> = HashMap::new();
    let (axis, val) = fold;

    for (&(mut x, mut y), &marked) in points {
        let marked = marked && !((axis == "x" && x == val) || (axis == "y" && val == y));
        if axis == "x" {
            x = if x > val { val - (x - val) } else { x };
        } else if axis == "y" {
            y = if y > val { val - (y - val) } else { y };
        }
        folded
            .entry((x, y))
            .and_modify(|x| *x = *x || marked)
            .or_insert(marked);
    }

    folded
}
