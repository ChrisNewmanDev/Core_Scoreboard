// Add close button and Escape key functionality
window.addEventListener('DOMContentLoaded', function () {
    const closeBtn = document.getElementById('closeScoreboard');
    if (closeBtn) {
        closeBtn.addEventListener('click', function () {
            fetch('https://core-scoreboard/closeScoreboard', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
            document.body.style.display = 'none';
        });
    }
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            fetch('https://core-scoreboard/closeScoreboard', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
            document.body.style.display = 'none';
        }
    });
});
window.addEventListener('message', function (event) {
    const data = event.data;

    if (data.type === "toggle") {
        document.body.style.display = data.show ? "block" : "none";
    }

    if (data.type === "update") {
        // Set server name from config
        const serverNameDiv = document.getElementById("server-name-banner");
        if (serverNameDiv && data.serverName) {
            serverNameDiv.textContent = data.serverName;
        }
        const playersDiv = document.getElementById("players");
        playersDiv.innerHTML = '';

        data.players.forEach(player => {
            const el = document.createElement("div");
            el.className = "player-row";
            el.innerHTML = `
                <span class="player-id">${player.id}</span>
                <span class="player-name">${player.name}</span>
                <span class="player-job">${player.job}</span>
            `;
            playersDiv.appendChild(el);
        });

        // Render jobs column
        const jobsListDiv = document.getElementById("jobs-list");
        jobsListDiv.innerHTML = '';
        if (data.jobs && data.jobOrder) {
            data.jobOrder.forEach(job => {
                if (data.jobs.hasOwnProperty(job)) {
                    const count = data.jobs[job];
                    let color = data.jobColors && data.jobColors[job] ? data.jobColors[job] : '';
                    // Use provided display name mapping if available
                    const displayName = (data.jobDisplayNames && data.jobDisplayNames[job]) ? data.jobDisplayNames[job] : (job.charAt(0).toUpperCase() + job.slice(1));
                    const jobEl = document.createElement('span');
                    jobEl.className = 'scoreboard-job-entry';
                    jobEl.style.display = 'inline-flex';
                    jobEl.style.alignItems = 'center';
                    jobEl.style.marginRight = '18px';
                    jobEl.innerHTML = `<span style="color:${color}">${displayName}</span>: <span style="color:${color};margin-left:2px;">${count}</span>`;
                    jobsListDiv.appendChild(jobEl);
                }
            });
        }

        // Render heists availability
        const heistsListDiv = document.getElementById("heists-list");
        heistsListDiv.innerHTML = '';
        // Configurable minimum PD required for heists (sent from Lua)
        const minPD = data.minPD || 0;
        const policeCount = data.jobs && data.jobs['police'] ? data.jobs['police'] : 0;
        if (data.heists && Array.isArray(data.heists)) {
            data.heists.forEach(heist => {
                const heistEl = document.createElement('div');
                heistEl.className = 'scoreboard-heist-entry';
                heistEl.style.display = 'flex';
                heistEl.style.flexDirection = 'row';
                heistEl.style.alignItems = 'center';
                heistEl.style.marginBottom = '6px';
                heistEl.style.whiteSpace = 'nowrap';
                heistEl.style.overflow = 'hidden';
                heistEl.style.textOverflow = 'ellipsis';
                const requiredPD = heist.minPD || 0;
                const nameSpan = document.createElement('span');
                nameSpan.textContent = heist.name;
                nameSpan.style.fontWeight = 'bold';
                nameSpan.style.marginRight = '8px';
                nameSpan.style.whiteSpace = 'nowrap';
                const statusSpan = document.createElement('span');
                statusSpan.style.whiteSpace = 'nowrap';
                if (heist.inProgress) {
                    statusSpan.innerHTML = '<small style="color: #f8e71c;">(In Progress)</small>';
                } else if (heist.cooldownRemaining && heist.cooldownRemaining > 0) {
                    const mins = Math.floor(heist.cooldownRemaining / 60);
                    const secs = heist.cooldownRemaining % 60;
                    statusSpan.innerHTML = `<small style=\"color: #e94e77;\">(Cooldown: ${mins}:${secs.toString().padStart(2, '0')})</small>`;
                } else if (policeCount >= requiredPD) {
                    statusSpan.innerHTML = '<small style="color: #7ed957;">(Available)</small>';
                } else {
                    statusSpan.innerHTML = `<small style=\"color: #e94e77;\">(Requires ${requiredPD} PD)</small>`;
                }
                heistEl.appendChild(nameSpan);
                heistEl.appendChild(statusSpan);
                heistsListDiv.appendChild(heistEl);
            });
        }
    }
});