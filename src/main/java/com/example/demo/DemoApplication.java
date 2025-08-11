package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Logger;

@SpringBootApplication
@RestController
public class DemoApplication {
	
	private static final Logger LOGGER = Logger.getLogger(DemoApplication.class.getName());

	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}
	
	// SQL Injection vulnerability
	@GetMapping("/search")
	public String search(@RequestParam String query) {
		String result = "No results found";
		try {
			Connection conn = DriverManager.getConnection("jdbc:h2:mem:testdb", "sa", "password");
			Statement stmt = conn.createStatement();
			
			// VULNERABLE: Direct use of user input in SQL query
			String sql = "SELECT * FROM users WHERE username = '" + query + "'";
			stmt.execute(sql);
			result = "Search completed";
		} catch (SQLException e) {
			LOGGER.warning("Database error: " + e.getMessage());
		}
		return result;
	}
	
	// Path traversal vulnerability
	@GetMapping("/file")
	public String readFile(@RequestParam String fileName) {
		// VULNERABLE: Direct use of user input for file paths
		File file = new File(fileName);
		try {
			// This could allow reading any file on the system
			return "File exists: " + file.exists() + ", Absolute path: " + file.getAbsolutePath();
		} catch (Exception e) {
			return "Error: " + e.getMessage();
		}
	}
	
	// Command injection vulnerability
	@GetMapping("/execute")
	public String executeCommand(@RequestParam String command) {
		try {
			// VULNERABLE: Direct use of user input in system commands
			Process process = Runtime.getRuntime().exec(command);
			return "Command executed with exit code: " + process.waitFor();
		} catch (IOException | InterruptedException e) {
			return "Error: " + e.getMessage();
		}
	}
}
