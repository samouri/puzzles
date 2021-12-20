use std::{collections::HashSet, fs};

pub fn solve() {
    let path = "src/day4/input.txt";
    let contents: Vec<Vec<u32>> = fs::read_to_string(path)
        .unwrap()
        .lines()
        .filter_map(|line| match line {
            "" => None,
            line => Some(
                line.replace(",", " ")
                    .split_whitespace()
                    .map(|num| num.parse::<u32>().unwrap())
                    .collect(),
            ),
        })
        .collect();

    let draws = &contents[0];
    let boards: Vec<Vec<u32>> = contents[1..]
        .iter()
        .flatten()
        .map(|n| *n)
        .collect::<Vec<u32>>()
        .chunks(25)
        .map(|c| c.to_vec())
        .collect();

    // Part 1
    let mut draw_set: HashSet<u32> = HashSet::new();
    'outer: for draw in draws {
        draw_set.insert(*draw);
        for board in &boards {
            if check_board(&board, &draw_set) {
                let sum = unmarked_sum(&board, &draw_set);
                println!("Part 1: {}", draw * sum);
                break 'outer;
            }
        }
    }

    // Part 2
    draw_set.clear();
    let mut boards2 = boards.clone();
    for draw in draws {
        draw_set.insert(*draw);
        if boards2.len() == 1 && check_board(&boards2[0], &draw_set) {
            let sum = unmarked_sum(&boards2[0], &draw_set);
            println!("Part 2: {}\n", draw * sum);
            return;
        }

        boards2 = boards2
            .into_iter()
            .filter(|board| !check_board(board, &draw_set))
            .collect();
    }
}

fn check_board(board: &Vec<u32>, draws: &HashSet<u32>) -> bool {
    for i in 0..5 {
        let row: HashSet<u32> = HashSet::from([
            board[i * 5],
            board[i * 5 + 1],
            board[i * 5 + 2],
            board[i * 5 + 3],
            board[i * 5 + 4],
        ]);
        let col: HashSet<u32> = HashSet::from([
            board[i],
            board[i + 5],
            board[i + 10],
            board[i + 15],
            board[i + 20],
        ]);
        if draws.is_superset(&row) || draws.is_superset(&col) {
            return true;
        }
    }
    return false;
}

fn unmarked_sum(board: &Vec<u32>, draws: &HashSet<u32>) -> u32 {
    (board).iter().filter(|n| !draws.contains(*n)).sum()
}
