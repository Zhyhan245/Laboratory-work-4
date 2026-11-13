PRAGMA foreign_keys = ON;

CREATE TABLE users (
    user_id INTEGER PRIMARY KEY
);

CREATE TABLE exercises (
    exercise_id INTEGER PRIMARY KEY,
    exercise_name VARCHAR(80) NOT NULL,
    description VARCHAR(500) NOT NULL,
    difficulty VARCHAR(20) NOT NULL,
    marker_instruction VARCHAR(500) NOT NULL,

    CONSTRAINT chk_exercise_name CHECK (
        exercise_name REGEXP
        '^[А-Яа-яІіЇїЄєҐґA-Za-z0-9][А-Яа-яІіЇїЄєҐґA-Za-z0-9 -]{1,79}$'
    ),

    CONSTRAINT chk_exercise_description CHECK (
        LENGTH(description) BETWEEN 1 AND 500
    ),

    CONSTRAINT chk_difficulty CHECK (
        difficulty REGEXP '^(Початковий|Середній|Високий)$'
    ),

    CONSTRAINT chk_marker_instruction CHECK (
        LENGTH(marker_instruction) BETWEEN 1 AND 500
    )
);

CREATE TABLE exercise_parameters (
    parameter_id INTEGER PRIMARY KEY,
    exercise_id INTEGER NOT NULL UNIQUE,
    min_tilt_angle FLOAT NOT NULL,
    max_tilt_angle FLOAT NOT NULL,
    allowed_position VARCHAR(50) NOT NULL,

    CONSTRAINT fk_parameters_exercise
        FOREIGN KEY (exercise_id)
        REFERENCES exercises (exercise_id),

    CONSTRAINT chk_min_angle CHECK (
        min_tilt_angle BETWEEN -180 AND 180
    ),

    CONSTRAINT chk_max_angle CHECK (
        max_tilt_angle BETWEEN -180 AND 180
    ),

    CONSTRAINT chk_angle_range CHECK (
        min_tilt_angle <= max_tilt_angle
    ),

    CONSTRAINT chk_allowed_position CHECK (
        LENGTH(allowed_position) BETWEEN 1 AND 50
    )
);

CREATE TABLE training_sessions (
    training_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    exercise_id INTEGER NOT NULL,

    CONSTRAINT fk_training_user
        FOREIGN KEY (user_id)
        REFERENCES users (user_id),

    CONSTRAINT fk_training_exercise
        FOREIGN KEY (exercise_id)
        REFERENCES exercises (exercise_id)
);

CREATE TABLE marker_measurements (
    measurement_id INTEGER PRIMARY KEY,
    training_id INTEGER NOT NULL,
    current_position VARCHAR(50) NOT NULL,
    tilt_angle FLOAT NOT NULL,

    CONSTRAINT fk_measurement_training
        FOREIGN KEY (training_id)
        REFERENCES training_sessions (training_id),

    CONSTRAINT chk_current_position CHECK (
        LENGTH(current_position) BETWEEN 1 AND 50
    ),

    CONSTRAINT chk_tilt_angle CHECK (
        tilt_angle BETWEEN -180 AND 180
    )
);

CREATE TABLE detected_deviations (
    deviation_id INTEGER PRIMARY KEY,
    measurement_id INTEGER NOT NULL UNIQUE,
    angle_deviation FLOAT NOT NULL,
    position_deviation VARCHAR(100) NOT NULL,

    CONSTRAINT fk_deviation_measurement
        FOREIGN KEY (measurement_id)
        REFERENCES marker_measurements (measurement_id),

    CONSTRAINT chk_angle_deviation CHECK (
        angle_deviation BETWEEN 0 AND 360
    ),

    CONSTRAINT chk_position_deviation CHECK (
        LENGTH(position_deviation) BETWEEN 1 AND 100
    )
);

CREATE TABLE analysis_results (
    result_id INTEGER PRIMARY KEY,
    training_id INTEGER NOT NULL UNIQUE,
    correctness_status VARCHAR(30) NOT NULL,

    CONSTRAINT fk_result_training
        FOREIGN KEY (training_id)
        REFERENCES training_sessions (training_id),

    CONSTRAINT chk_correctness CHECK (
        correctness_status IN (
            'Правильно',
            'Потребує корекції'
        )
    )
);
