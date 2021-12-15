use std::fs;

pub fn solve() -> std::io::Result<()> {
    let path = "src/day15/example.txt";
    let file_content: String = fs::read_to_string(path).unwrap();

    let risk_map: Vec<Vec<usize>> = file_content
        .lines()
        .map(|l| {
            l.chars()
                .map(|c| c.to_digit(10).unwrap() as usize)
                .collect()
        })
        .collect();
    let mut acc_graph: Vec<Vec<usize>> = risk_map
        .clone()
        .iter()
        .map(|v| v.iter().map(|_x| usize::MAX).collect())
        .collect();
    acc_graph[0][0] = 0;

    alt(&risk_map, &mut acc_graph, 0, 0);
    // println!("Part 1: {}", bfs(&risk_map, 0, 0, 0));
    // println!("Part 1: {:?}", acc_graph.last().unwrap().last().unwrap());
    println!("Part 1: {:?}", acc_graph);
    Ok(())
}

fn alt(risk_map: &Vec<Vec<usize>>, acc: &mut Vec<Vec<usize>>, row: usize, col: usize) {
    let at_row_end = row == risk_map.len() - 1;
    let at_col_end = col == risk_map.last().unwrap().len() - 1;
    let curr = acc[row][col];

    if !at_col_end {
        let next_val = curr + risk_map[row][col + 1];
        if next_val < acc[row][col + 1] {
            acc[row][col + 1] = next_val;
            alt(risk_map, acc, row, col + 1);
        }
    }
    if !at_row_end {
        let next_val = curr + risk_map[row + 1][col];
        if next_val < acc[row + 1][col] {
            acc[row + 1][col] = next_val;
            alt(risk_map, acc, row + 1, col);
        }
    }
}
