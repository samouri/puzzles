use std::cmp::{max, min};
use std::convert::TryFrom;
use std::{collections::HashMap, fs};

pub fn solve() {
    let path = "src/day5/input.txt";
    let lines: Vec<Line> = fs::read_to_string(path)
        .unwrap()
        .lines()
        .map(|s: &str| {
            let stripped: String = s.replace(" -> ", ",");
            let [x0, x1, y0, y1] =
                (<[&str; 4]>::try_from(stripped.split(",").collect::<Vec<&str>>())).unwrap();
            Line(
                x0.parse().unwrap(),
                x1.parse().unwrap(),
                y0.parse().unwrap(),
                y1.parse().unwrap(),
            )
        })
        .collect();

    // Part 1
    let map: &mut HashMap<i32, HashMap<i32, i32>> = &mut HashMap::new();
    for line in &lines {
        insert_line(line, map);
    }
    let count = map
        .values()
        .flat_map(|inner_map| inner_map.values())
        .filter(|c| (*(*c)) >= 2)
        .count();
    println!("Part 1: {}", count);

    for line in &lines {
        insert_diagonal(line, map);
    }
    let count = map
        .values()
        .flat_map(|inner_map| inner_map.values())
        .filter(|c| (*(*c)) >= 2)
        .count();
    println!("Part 2: {}\n", count);
}

#[derive(Debug)]
struct Line(i32, i32, i32, i32);

fn insert_line(line: &Line, map: &mut HashMap<i32, HashMap<i32, i32>>) {
    let Line(x0, y0, x1, y1) = *line;

    // horizontal line
    if y0 == y1 {
        let min = min(x0, x1);
        let max = max(x0, x1);
        for i in min..(max + 1) {
            insert_point(i, y0, map)
        }
    }

    // vertical line
    if x0 == x1 {
        let min = min(y0, y1);
        let max = max(y0, y1);
        for i in min..(max + 1) {
            insert_point(x0, i, map)
        }
    }
}

fn insert_diagonal(line: &Line, map: &mut HashMap<i32, HashMap<i32, i32>>) {
    let Line(x0, y0, x1, y1) = *line;
    if x0 == x1 || y0 == y1 {
        return;
    }

    let x_vel: i32 = if x0 < x1 { 1 } else { -1 };
    let y_vel: i32 = if y0 < y1 { 1 } else { -1 };

    for i in 0..((x0 - x1).abs() + 1) {
        // println!("{},{}->{},{}: {},{}", x0, y0, x1, y1, min_x + i, min_y + i);
        insert_point(x0 + (i * x_vel), y0 + (i * y_vel), map);
    }
}

fn insert_point(x: i32, y: i32, map: &mut HashMap<i32, HashMap<i32, i32>>) {
    if !map.contains_key(&x) {
        map.insert(x, HashMap::new());
    }

    let map2: &mut HashMap<i32, i32> = map.get_mut(&x).unwrap();
    if map2.contains_key(&y) {
        map2.insert(y, map2.get(&y).unwrap() + 1);
    } else {
        map2.insert(y, 1);
    }
}
