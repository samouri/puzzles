use std::fs;

fn main() -> std::io::Result<()> {
  let path = "src/01/input.txt";
  let contents = fs::read_to_string(path).expect("Something went wrong reading the file");
  let lines = contents.lines();
  let nums: Vec<i32> = lines.map(|n| n.parse::<i32>().unwrap()).collect();

  let mut count = 0;
  for i in 1..nums.len() {
    if nums[i] > nums[i - 1] {
      count += 1
    }
  }

  println!("Answer: {}\n", count);
  Ok(())
}
