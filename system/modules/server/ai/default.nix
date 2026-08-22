{
  imports = [
    # llama.cpp CPU inference stack (llama-server behind llama-swap).
    ./llama-cpp
    # Persistent web GUI, pointed at the local llama-swap endpoint.
    ./open-webui
  ];
}
