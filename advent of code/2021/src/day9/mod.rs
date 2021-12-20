use std::collections::HashSet;

pub fn solve() {
    let contents = include_str!("./input.txt");
    println!("Part 1: {}", part_one(contents));
    println!("Part 2: {}", part_two(contents));
    println!("");
}

fn preprocess(contents: &str) -> Vec<Vec<usize>> {
    contents
        .lines()
        .map(|s| {
            s.chars()
                .map(|c| c.to_digit(10).unwrap() as usize)
                .collect()
        })
        .collect()
}

fn part_one(contents: &str) -> usize {
    let heights = preprocess(contents);
    let mut smallest: Vec<usize> = Vec::new();
    for (i, row) in heights.iter().enumerate() {
        for (j, _) in row.iter().enumerate() {
            let val = heights[i][j];
            let is_smallest = neighbors(i, j, &heights)
                .iter()
                .all(|&(x, j)| val < heights[x][j]);
            if is_smallest {
                smallest.push(heights[i][j]);
            }
        }
    }
    smallest.iter().map(|x| x + 1).sum()
}

fn part_two(contents: &str) -> usize {
    let heights = preprocess(contents);
    let mut basins: Vec<usize> = vec![];
    let mut seen: HashSet<(usize, usize)> = HashSet::new();
    for (i, row) in heights.iter().enumerate() {
        for (j, _) in row.iter().enumerate() {
            basins.push(find_basin(&heights, &mut seen, i, j));
        }
    }
    basins.sort_by(|a, b| b.cmp(a));

    (basins[0] * basins[1] * basins[2]) as usize
}

fn find_basin(
    heights: &Vec<Vec<usize>>,
    seen: &mut HashSet<(usize, usize)>,
    x: usize,
    y: usize,
) -> usize {
    if seen.contains(&(x, y)) {
        return 0;
    }
    seen.insert((x, y));
    if heights[x][y] == 9 {
        return 0;
    }

    1 + neighbors(x, y, heights)
        .iter()
        .map(|&(x, y)| find_basin(heights, seen, x, y))
        .sum::<usize>()
}

fn neighbors(x: usize, y: usize, heights: &Vec<Vec<usize>>) -> Vec<(usize, usize)> {
    let x = x as i32;
    let y = y as i32;
    let row_len = heights.len() as i32;
    let col_len = heights.last().unwrap().len() as i32;
    vec![(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]
        .into_iter()
        .filter(|&(x, y)| (0 <= x && x < row_len) && (0 <= y && y < col_len))
        .map(|(x, y)| (x as usize, y as usize))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn part_1() {
        let contents = include_str!("./example.txt");
        assert_eq!(part_one(contents), 15);
    }

    #[test]
    fn part_2() {
        let contents = include_str!("./example.txt");
        assert_eq!(part_two(contents), 1134);
    }
}
