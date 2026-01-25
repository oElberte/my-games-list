# Home Feature Documentation

## Overview
Manages the home screen and main dashboard functionality.

## Architecture
**Feature-First Structure**:
- `home_screen.dart`: Main dashboard UI.
- `item_model.dart`: Data model for items.
- `bloc/`: Contains `HomeBloc`, `HomeEvent`, `HomeState`.

### Dependencies
- `HomeBloc` (Factory): Manages home screen state.

## Key Components
- **HomeBloc**: Handles business logic for fetching items and toggling favorites.
- **HomeScreen**: Displays list of items with favorite toggle.

## Testing Strategy
- Unit test `HomeBloc`.
- Widget test `HomeScreen`.
