package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

// GreetingResponse represents the JSON output for the greeting endpoint.
type GreetingResponse struct {
	Message   string `json:"message"`
	Timestamp string `json:"timestamp"`
}

// HealthResponse represents the health probe output.
type HealthResponse struct {
	Status string `json:"status"`
}

// GreetingHandler handles requests to the root path.
func GreetingHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	resp := GreetingResponse{
		Message:   "Hello from Go!",
		Timestamp: time.Now().UTC().Format(time.RFC3339),
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(resp)
}

// HealthHandler handles liveness and readiness probes.
func HealthHandler(w http.ResponseWriter, _ *http.Request) {
	resp := HealthResponse{
		Status: "healthy",
	}
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(resp)
}

// SetupRouter sets up HTTP routes.
func SetupRouter() *http.ServeMux {
	mux := http.NewServeMux()
	mux.HandleFunc("/", GreetingHandler)
	mux.HandleFunc("/health", HealthHandler)
	return mux
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	mux := SetupRouter()
	server := &http.Server{
		Addr:              fmt.Sprintf(":%s", port),
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}

	log.Printf("Go HTTP server listening on port %s...", port)
	if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatalf("Server error: %v", err)
	}
}
