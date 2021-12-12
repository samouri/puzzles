use std::fs;

pub fn solve() -> std::io::Result<()> {
    let path = "src/day9/input.txt";
    let heightmap: Vec<Vec<i32>> = fs::read_to_string(path)
        .unwrap()
        .lines()
        .map(|s| s.chars().map(|c| c.to_digit(10).unwrap() as i32).collect())
        .collect();
    let heights = &heightmap;

    let mut smallest: Vec<i32> = Vec::new();
    for i in 0..heights.len() {
        for j in 0..heights[i].len() {
            let val = heightmap[i][j];
            let is_smallest = neighbors(i as i32, j as i32, heights)
                .iter()
                .all(|(x, j)| heightmap[(*x) as usize][(*j) as usize] > val);
            if is_smallest {
                smallest.push(heightmap[i][j]);
            }
        }
    }
    println!("Part 1: {}", smallest.len() as i32);

    Ok(())
}

fn neighbors(x: i32, y: i32, heights: &Vec<Vec<i32>>) -> Vec<(i32, i32)> {
    vec![(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]
        .into_iter()
        .filter(|(i, j)| {
            heights.get((*i) as usize).is_some()
                && heights[(*i) as usize].get((*j) as usize).is_some()
        })
        .collect()
}